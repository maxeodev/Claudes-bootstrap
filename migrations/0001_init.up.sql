-- Brume control-plane initial schema.
--
-- Tenancy & deploy model:
--   User -> Team -> Project -> App -> Environment (k8s namespace) -> Deployment
--   An App defines build config + one or more Processes (web/worker/cron).
--   An Environment (production/staging/...) holds its own env vars, domains,
--   addons and deployments. A Release (image build) is shared across envs.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email         TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- A team is the tenant boundary (one client = one team).
CREATE TABLE teams (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       TEXT NOT NULL,
    slug       TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE team_members (
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role    TEXT NOT NULL DEFAULT 'member', -- 'owner' | 'member'
    PRIMARY KEY (team_id, user_id)
);

-- A project is a logical grouping of apps for a team.
CREATE TABLE projects (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id    UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    name       TEXT NOT NULL,
    slug       TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (team_id, slug)
);

-- An app is a deployable codebase built from a Dockerfile.
-- release_command is an optional pre-deploy hook (e.g. DB migrations) run
-- before traffic is shifted to a new release.
CREATE TABLE apps (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id      UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name            TEXT NOT NULL,
    slug            TEXT NOT NULL,
    git_repo_url    TEXT,
    git_branch      TEXT NOT NULL DEFAULT 'main',
    dockerfile_path TEXT NOT NULL DEFAULT 'Dockerfile',
    build_context   TEXT NOT NULL DEFAULT '.',
    release_command TEXT,                         -- pre-deploy hook (migrations)
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (project_id, slug)
);

-- Process types within an app: a web process gets an ingress; workers run
-- continuously; cron processes run on a schedule. Resilience & autoscaling
-- knobs live per process.
CREATE TABLE app_processes (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id                 UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    type                   TEXT NOT NULL,             -- 'web' | 'worker' | 'cron'
    name                   TEXT NOT NULL,             -- e.g. 'web', 'worker', 'nightly'
    command                TEXT,                      -- overrides image CMD
    container_port         INT,                       -- web only
    health_check_path      TEXT NOT NULL DEFAULT '/', -- web only
    cron_schedule          TEXT,                      -- cron only (crontab syntax)
    -- Resilience.
    min_replicas           INT  NOT NULL DEFAULT 2,
    -- Autoscaling.
    max_replicas           INT  NOT NULL DEFAULT 5,
    autoscaling_enabled    BOOLEAN NOT NULL DEFAULT TRUE,
    cpu_target_percent     INT  NOT NULL DEFAULT 75,
    -- Resource requests/limits.
    cpu_request_millicores INT  NOT NULL DEFAULT 100,
    memory_request_mb      INT  NOT NULL DEFAULT 128,
    cpu_limit_millicores   INT  NOT NULL DEFAULT 500,
    memory_limit_mb        INT  NOT NULL DEFAULT 512,
    UNIQUE (app_id, name),
    CHECK (type IN ('web', 'worker', 'cron')),
    CHECK (min_replicas >= 1),
    CHECK (max_replicas >= min_replicas),
    CHECK (type <> 'web' OR container_port IS NOT NULL),
    CHECK (type <> 'cron' OR cron_schedule IS NOT NULL)
);

-- An environment (production, staging, ...) maps 1:1 to an isolated namespace,
-- enabling per-environment ResourceQuota and NetworkPolicy.
CREATE TABLE environments (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id        UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    name          TEXT NOT NULL,                       -- 'production' | 'staging' | ...
    k8s_namespace TEXT NOT NULL UNIQUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (app_id, name)
);

-- Environment variables / secrets, scoped per environment. Secret values are
-- encrypted at rest before storage.
CREATE TABLE env_vars (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    environment_id  UUID NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    key             TEXT NOT NULL,
    value_encrypted BYTEA NOT NULL,
    is_secret       BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (environment_id, key)
);

-- Hostnames routed to an environment's web process via Traefik ingress.
CREATE TABLE domains (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    environment_id UUID NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    hostname       TEXT UNIQUE NOT NULL,
    tls_enabled    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Managed addons (Postgres/MySQL/Redis/...) provisioned for an environment.
-- Connection details are injected into the app via a generated secret.
CREATE TABLE addons (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    environment_id     UUID NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    type               TEXT NOT NULL,                 -- 'postgres' | 'mysql' | 'redis'
    plan               TEXT NOT NULL DEFAULT 'small',
    status             TEXT NOT NULL DEFAULT 'pending',
    connection_secret  TEXT,                          -- name of the k8s secret
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- A release is the result of building an app's Dockerfile into an image.
-- It is environment-agnostic and can be promoted across environments.
CREATE TABLE releases (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id         UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    git_commit_sha TEXT,
    image_ref      TEXT,
    status         TEXT NOT NULL DEFAULT 'pending', -- pending|building|succeeded|failed
    build_logs     TEXT,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    finished_at    TIMESTAMPTZ
);

-- A deployment is a rollout of a release into a specific environment.
CREATE TABLE deployments (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    environment_id UUID NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    release_id     UUID NOT NULL REFERENCES releases(id),
    status         TEXT NOT NULL DEFAULT 'pending', -- pending|progressing|healthy|failed|rolledback
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_projects_team ON projects(team_id);
CREATE INDEX idx_apps_project ON apps(project_id);
CREATE INDEX idx_app_processes_app ON app_processes(app_id);
CREATE INDEX idx_environments_app ON environments(app_id);
CREATE INDEX idx_env_vars_env ON env_vars(environment_id);
CREATE INDEX idx_domains_env ON domains(environment_id);
CREATE INDEX idx_addons_env ON addons(environment_id);
CREATE INDEX idx_releases_app ON releases(app_id);
CREATE INDEX idx_deployments_env ON deployments(environment_id);
