#!/usr/bin/env bash
set -aeuo pipefail

echo "Running setup.sh"
echo "Waiting until all configurations are healthy/installed..."
"${KUBECTL}" wait configuration.pkg --all --for=condition=Healthy --timeout 5m
"${KUBECTL}" wait configuration.pkg --all --for=condition=Installed --timeout 5m

echo "Creating generic credential secret..."
"${KUBECTL}" -n upbound-system create secret generic creds --from-literal=credentials="${UPTEST_CLOUD_CREDENTIALS}" \
    --dry-run=client -o yaml | "${KUBECTL}" apply -f -

echo "Waiting until all installed provider packages are healthy..."
"${KUBECTL}" wait provider.pkg --all --for condition=Healthy --timeout 5m

echo "Waiting for all pods to come online..."
"${KUBECTL}" -n upbound-system wait --for=condition=Available deployment --all --timeout=5m

echo "Waiting for all XRDs to be established..."
"${KUBECTL}" wait xrd --all --for condition=Established

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${KUBECTL}" apply -f "${SCRIPT_DIR}"/providerconfig.yaml
