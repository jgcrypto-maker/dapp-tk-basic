#!/usr/bin/env sh
# Verifies that the local Anvil deployment matches the expected launch values.
# Runs inside the contracts container with the repo mounted at /workspace.
set -eu

RPC="${ANVIL_RPC:-http://anvil:8545}"
FILE="${DEPLOYMENT_FILE:-deployments/dev.json}"

if [ ! -f "$FILE" ]; then
  echo "no existe $FILE: ejecuta 'make deploy-local' antes" >&2
  exit 1
fi

SALE=$(sed -n 's/.*"sale": "\(0x[0-9a-fA-F]*\)".*/\1/p' "$FILE" | head -n 1)
TOKEN=$(sed -n 's/.*"token": "\(0x[0-9a-fA-F]*\)".*/\1/p' "$FILE" | head -n 1)

if [ -z "$SALE" ] || [ -z "$TOKEN" ]; then
  echo "no se pudieron leer las direcciones de $FILE" >&2
  exit 1
fi

fail=0
expect() { # nombre, obtenido, esperado
  if [ "$2" = "$3" ]; then
    echo "OK    $1 = $2"
  else
    echo "FALLO $1: obtenido '$2', esperado '$3'" >&2
    fail=1
  fi
}
call() { cast call "$1" "$2" --rpc-url "$RPC" | awk '{print $1}'; }

expect "chainId"              "$(cast chain-id --rpc-url "$RPC")"                     "31337"
expect "sale.token"           "$(call "$SALE" 'token()(address)')"                    "$TOKEN"
expect "pricePerTokenWei"     "$(call "$SALE" 'pricePerTokenWei()(uint256)')"         "10000000000000000"
expect "inventory"            "$(call "$SALE" 'inventory()(uint256)')"                "1000000000000000000000000"
expect "remainingTokens"      "$(call "$SALE" 'remainingTokens()(uint256)')"          "1000000000000000000000000"
expect "totalTokensSold"      "$(call "$SALE" 'totalTokensSold()(uint256)')"          "0"
expect "totalRaisedWei"       "$(call "$SALE" 'totalRaisedWei()(uint256)')"           "0"
expect "token.totalSupply"    "$(call "$TOKEN" 'totalSupply()(uint256)')"             "1000000000000000000000000"
expect "token.symbol"         "$(cast call "$TOKEN" 'symbol()(string)' --rpc-url "$RPC" | tr -d '"')" "TK"

if [ "$fail" -eq 0 ]; then
  echo "DEV correcto"
else
  echo "DEV con errores" >&2
  exit 1
fi
