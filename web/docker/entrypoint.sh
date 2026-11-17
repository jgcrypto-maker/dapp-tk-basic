#!/bin/sh
# Generates the runtime configuration for the static export and copies the deployment
# file mounted at /config. Validates values so a bad quote cannot produce invalid JSON.
set -eu

CHAIN_ID="${CHAIN_ID:-31337}"
RPC_URL="${RPC_URL:-http://localhost:8545}"
EXPLORER_URL="${EXPLORER_URL:-}"
POL_USD_RATE="${POL_USD_RATE:-0.1}"
ENV_NAME="${ENV_NAME:-dev}"
DEPLOYMENT_FILE="${DEPLOYMENT_FILE:-/config/deployment.json}"

case "$CHAIN_ID" in
  "" | *[!0-9]*)
    echo "CHAIN_ID debe ser numérico" >&2
    exit 1
    ;;
esac

case "$POL_USD_RATE" in
  "" | *[!0-9.]*)
    echo "POL_USD_RATE debe ser numérico" >&2
    exit 1
    ;;
esac

case "$RPC_URL$EXPLORER_URL$ENV_NAME" in
  *'"'* | *'\'*)
    echo "Valores con comillas o barras invertidas no permitidos" >&2
    exit 1
    ;;
esac

printf '{"env":"%s","chainId":%s,"rpcUrl":"%s","explorerUrl":"%s","polUsdRate":%s}\n' \
  "$ENV_NAME" "$CHAIN_ID" "$RPC_URL" "$EXPLORER_URL" "$POL_USD_RATE" > /srv/config.json

if [ -f "$DEPLOYMENT_FILE" ]; then
  cp "$DEPLOYMENT_FILE" /srv/deployment.json
fi

exec "$@"
