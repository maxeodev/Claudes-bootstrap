#!/usr/bin/env bash
#
# Brume installer (skeleton — fleshed out in P7).
#
# Provisions a single server into a Brume node:
#   1. installs k3s (with Traefik ingress)
#   2. installs cert-manager
#   3. deploys the in-cluster image registry
#   4. installs the observability stack (Prometheus / Grafana / Loki / Alertmanager)
#   5. deploys the Brume control-plane onto the cluster
#
# Additional servers join the cluster with the printed `k3s agent` command.
#
# Usage: BRUME_BASE_DOMAIN=apps.example.com ./deploy/install.sh
set -euo pipefail

log() { printf '\033[1;36m[brume]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[brume] error:\033[0m %s\n' "$*" >&2; exit 1; }

require_root() {
  [ "$(id -u)" -eq 0 ] || die "please run as root (k3s install needs it)"
}

install_k3s() {
  if command -v k3s >/dev/null 2>&1; then
    log "k3s already installed, skipping"
    return
  fi
  log "installing k3s..."
  # TODO(P7): pin version, configure Traefik, expose kubeconfig.
  die "not implemented yet — see docs/ROADMAP.md (P7)"
}

main() {
  require_root
  install_k3s
  # TODO(P7): install_cert_manager, install_registry, install_observability,
  #           deploy_control_plane, print_join_command.
  log "done"
}

main "$@"
