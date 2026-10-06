#!/usr/bin/env bash
# Renders the ALB controller chart into rendered.yaml (run after changing VERSION or values.yaml, then commit).
# Helm hooks are left out: Argo CD doesn't run Helm pre-delete hooks, and the hook Job isn't policy-compliant.
set -euo pipefail
cd "$(dirname "$0")"
VERSION=1.12.2
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
helm pull oci://mcr.microsoft.com/application-lb/charts/alb-controller --version "$VERSION" -d "$TMP" >/dev/null 2>&1
helm template alb-controller "$TMP/alb-controller-$VERSION.tgz" \
  --namespace azure-alb-system --no-hooks -f values.yaml > rendered.yaml
# Bain's AKS policy denies containers that don't set allowPrivilegeEscalation: false (kustomization.yaml patches it).
missing=$(kubectl kustomize . | yq -N 'select(.spec.template.spec != null) | .metadata.name as $o | ((.spec.template.spec.initContainers // []) + .spec.template.spec.containers)[] | select(.securityContext.allowPrivilegeEscalation != false) | $o + ":" + .name')
if [ -n "$missing" ]; then echo "Containers without allowPrivilegeEscalation: false: $missing" >&2; exit 1; fi
echo "Rendered chart $VERSION; every container sets allowPrivilegeEscalation: false."
