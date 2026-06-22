-- Brume control-plane initial schema.
-- Tenancy model: User -> Team -> Project (k8s namespace) -> App -> Release -> Deployment.

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

-- A project maps 1:1 to an isolated Kubernetes namespace.
CREATE TABLE projects (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id       UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    name          TEXT NOT NULL,
    slug          TEXT NOT NULL,
    k8s_namespace TEXT NOT NULL UNIQUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (team_id, slug)
);

-- An app is a deployable unit built from a Dockerfile.
-- Resilience & autoscaling defaults live here (pillars).
CREATE TABLE apps (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id             UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name                   TEXT NOT NULL,
    slug                   TEXT NOT NULL,
    git_repo_url           TEXT,
    git_branch             TEXT NOT NULL DEFAULT 'main',
    dockerfile_path        TEXT NOT NULL DEFAULT 'Dockerfile',
    container_port         INT  NOT NULL DEFAULT 8080,
    health_check_path      TEXT NOT NULL DEFAULT '/',
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
    created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (project_id, slug),
    CHECK (min_replicas >= 1),
    CHECK (max_replicas >= min_replicas)
);

-- Environment variables / secrets. Secret values are encrypted at rest.
CREATE TABLE app_env_vars (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id          UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    key             TEXT NOT NULL,
    value_encrypted BYTEA NOT NULL,
    is_secret       BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (app_id, key)
);

-- Custom or generated hostnames routed to an app via Traefik ingress.
CREATE TABLE app_domains (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id      UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    hostname    TEXT UNIQUE NOT NULL,
    tls_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- A release is the result of building an app's Dockerfile into an image.
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

-- A deployment is a rollout of a release onto the cluster.
CREATE TABLE deployments (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id     UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    release_id UUID NOT NULL REFERENCES releases(id),
    status     TEXT NOT NULL DEFAULT 'pending', -- pending|progressing|healthy|failed|rolledback
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_projects_team ON projects(team_id);
CREATE INDEX idx_apps_project ON apps(project_id);
CREATE INDEX idx_releases_app ON releases(app_id);
CREATE INDEX idx_deployments_app ON deployments(app_id);
