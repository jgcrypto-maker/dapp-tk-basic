# Convenciones de nombrado

> **Regla base:** los archivos, directorios, funciones, variables, tipos y comentarios de código se escriben **en inglés**. La **documentación se redacta en español**, pero su nombre de archivo también es en inglés.

Esta regla aplica a todo el repositorio, incluidos contratos, web, Docker, scripts y CI. El objetivo es que el proyecto se lea igual que cualquier proyecto open source del ecosistema y que buscar un identificador (`grep`) tenga un resultado predecible.

---

## 1. Archivos y directorios

Regla general: **inglés, ASCII, sin espacios, sin acentos y sin `ñ`**.

| Tipo | Convención | Ejemplo correcto | Ejemplo incorrecto |
|---|---|---|---|
| Carpetas | `kebab-case` | `sale-panel/`, `deployments/` | `PanelVenta/`, `despliegues/` |
| Documentación | `SCREAMING_SNAKE.md` | `ARCHITECTURE.md`, `NAMING.md` | `ARQUITECTURA.md`, `arquitectura.md` |
| Contratos | `PascalCase.sol` | `TokenSale.sol`, `SaleToken.sol` | `ventaToken.sol`, `token_sale.sol` |
| Tests Foundry | `<Contrato>.t.sol` | `TokenSale.t.sol`, `TokenSale.invariants.t.sol` | `test_venta.sol` |
| Componentes React | `PascalCase.tsx` | `SalePanel.tsx`, `WalletLookup.tsx` | `panelVenta.tsx`, `sale-panel.tsx` |
| Hooks | `use<PascalCase>.ts` | `useSaleState.ts`, `useBuyTokens.ts` | `useEstadoVenta.ts` |
| Utilidades TS | `kebab-case.ts` | `format-amount.ts`, `parse-address.ts` | `formatoImporte.ts` |
| Configuración | minúsculas estándar | `compose.pre.yaml`, `foundry.toml`, `package.json` | `Compose-PRE.yaml` |
| Entornos | `.env.<entorno>` | `.env.example`, `.env.dev`, `.env.pre`, `.env.pro` | `.env.local.venta` |
| Despliegues | `<chainId>.json` | `deployments/80002.json`, `deployments/137.json` | `deployments/amoy.json` |
| Scripts | `kebab-case.sh` | `check-file-names.sh` | `comprobarNombres.sh` |

**Excepciones obligatorias del framework** (no se renombran): `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`, `route.ts`, `middleware.ts`, `next.config.ts`. También se permiten `README.md`, `LICENSE`, `Dockerfile`, `Makefile`, `.gitignore`, `.dockerignore`, `.editorconfig`, `.gitattributes`, `.nvmrc`, `CODEOWNERS`, `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `PULL_REQUEST_TEMPLATE.md`, el directorio `.github/ISSUE_TEMPLATE/` y los lockfiles.

---

## 2. Contratos Solidity

| Elemento | Convención | Ejemplo |
|---|---|---|
| Contrato / interface / library | `PascalCase` | `TokenSale`, `ITokenSale` |
| Struct / enum | `PascalCase` | `SaleState`, `SaleStatus` |
| Función | `camelCase`, verbo primero | `buy`, `buyFor`, `quote`, `withdrawProceeds` |
| Variable de estado / local | `camelCase` en inglés | `totalTokensSold`, `remainingTokens` |
| Constante / `immutable` | `UPPER_SNAKE_CASE` | `MAX_TOKENS_PER_WALLET`, `TOKEN_DECIMALS` |
| Privada / interna | `_` + `camelCase` | `_buyers`, `_isBuyer` |
| Evento | `PascalCase`, en pasado | `TokensPurchased`, `PriceUpdated` |
| Error | `PascalCase`, condición | `SoldOut`, `IncorrectPayment`, `AboveWalletCap` |
| Modifier | `camelCase` | `whenSaleActive`, `onlyOwner` |
| Parámetro | `camelCase` con unidad si aplica | `tokenAmount`, `pricePerTokenWei` |

Reglas adicionales:

- Booleanos con prefijo `is`, `has`, `can` o `should` (`isBuyer`, `hasEnded`).
- Unidades explícitas en el nombre cuando hay riesgo: `amountWei`, `pricePerTokenWei`, `tokenAmount`.
- Nada de abreviaturas inventadas. Se aceptan las universales: `id`, `url`, `tx`, `wei`, `abi`.
- Comentarios y `NatSpec` en inglés.

---

## 3. TypeScript y React

| Elemento | Convención | Ejemplo |
|---|---|---|
| Componente | `PascalCase` | `SalePanel`, `BuyForm` |
| Props / tipos | `PascalCase`, sin prefijo `I` | `SalePanelProps`, `BuyFormValues` |
| Hook | `use` + `PascalCase` | `useSaleState`, `useWalletLookup` |
| Función | `camelCase`, verbo primero | `formatPol`, `parseTokenAmount` |
| Variable | `camelCase` | `remainingTokens`, `isConnected` |
| Constante | `UPPER_SNAKE_CASE` | `DEFAULT_CHAIN_ID`, `POLL_INTERVAL_MS` |
| Clave i18n | inglés, `namespace.key` | `sale.buyButton`, `wallet.lookupTitle` |

- Nada de `any`; los tipos de contrato se generan desde la ABI.
- Los imports usan alias `@/` y rutas en inglés (`@/lib/format-amount`).
- Los nombres de archivo de páginas siguen la excepción del framework (§1).

---

## 4. Variables de entorno y Docker

| Elemento | Convención | Ejemplo |
|---|---|---|
| Variable pública de Next | `NEXT_PUBLIC_` + `UPPER_SNAKE` | `NEXT_PUBLIC_CHAIN_ID` |
| RPC / API | `UPPER_SNAKE` con proveedor | `ETH_RPC_URL`, `POLYGONSCAN_API_KEY` |
| Servicio Compose | `kebab-case` | `web`, `contracts`, `edge`, `db`, `indexer` |
| Imagen | `ghcr.io/<org>/dapp-tk-<servicio>:<tag>` | `ghcr.io/acme/dapp-tk-web:sha-abc123` |
| Red / volumen | `snake_case` o `kebab-case` consistente | `internal`, `edge`, `web_node_modules` |

- Un secreto **nunca** lleva prefijo `NEXT_PUBLIC_` (acabaría en el bundle).
- Toda variable nueva se documenta en `.env.example` con un valor ficticio.

---

## 5. Documentación y textos de interfaz

| Ámbito | Idioma | Ejemplo |
|---|---|---|
| Documentos (`docs/*.md`) | **Español** | “Modelo on-chain y contabilidad” |
| Nombre del documento | **Inglés** | `ARCHITECTURE.md` |
| Comentarios de código | **Inglés** | `// Reverts when the wallet cap is exceeded` |
| Identificadores | **Inglés** | `maxTokensPerWallet` |
| Textos visibles de la UI | **Español** | “Comprar tokens”, “Quedan 12.400 TK” |
| Claves de traducción | **Inglés** | `sale.buyButton` |

La UI se prepara para i18n con `es` como idioma por defecto y `en` como segundo. Las claves siempre en inglés; los valores, traducidos.

---

## 6. Git

- Ramas: `feat/<scope>`, `fix/<scope>`, `chore/<scope>`, `docs/<scope>` — en inglés y `kebab-case`: `feat/buy-flow`, `fix/wallet-cap`.
- Commits: [Conventional Commits](https://www.conventionalcommits.org/) en inglés: `feat(sale): add wallet lookup`, `fix(web): handle rejected signature`.
- Títulos de PR en inglés; la descripción puede ir en español si el equipo lo prefiere.
- Tags de release: `v0.1.0`, `v0.2.0`.

---

## 7. Aplicación automática

### 7.1 ESLint (TypeScript)

```json
{
  "rules": {
    "@typescript-eslint/naming-convention": [
      "error",
      { "selector": "default", "format": ["camelCase"] },
      { "selector": "variable", "format": ["camelCase", "UPPER_CASE"] },
      { "selector": "function", "format": ["camelCase"] },
      { "selector": "typeLike", "format": ["PascalCase"] },
      { "selector": "objectLiteralProperty", "format": null }
    ]
  }
}
```

### 7.2 Solhint (Solidity)

```json
{
  "rules": {
    "contract-name-camelcase": "error",
    "event-name-camelcase": "error",
    "func-name-mixedcase": "error",
    "var-name-mixedcase": "error",
    "const-name-snakecase": "error",
    "modifier-name-mixedcase": "error"
  }
}
```

### 7.3 Script de nombres de archivo

`scripts/check-file-names.sh` falla si un archivo no cumple la convención o si la ruta contiene caracteres no ASCII:

```bash
#!/usr/bin/env bash
set -euo pipefail

fail=0

check() {
  local file="$1" regex="$2"
  local base
  base="$(basename "$file")"
  if ! [[ "$base" =~ $regex ]]; then
    echo "naming: '$file' does not match '$regex'" >&2
    fail=1
  fi
}

# Archivos que no siguen la convención por imperativo del framework o del estándar
is_exempt() {
  case "$1" in
    README.md|ARCHITECTURE.md|NAMING.md|LICENSE|Dockerfile|Makefile) return 0 ;;
    .env.example|.gitignore|.dockerignore|pnpm-lock.yaml|foundry.lock) return 0 ;;
    next.config.ts|page.tsx|layout.tsx|loading.tsx|error.tsx|not-found.tsx|route.ts|middleware.ts) return 0 ;;
  esac
  return 1
}

while IFS= read -r -d '' file; do
  case "$file" in
    ./.git/*|*/node_modules/*|./out/*|./cache/*) continue ;;
  esac

  base="$(basename "$file")"
  if is_exempt "$base"; then
    continue
  fi

  ext="${base##*.}"
  case "$ext" in
    sol)  check "$file" '^[A-Z][A-Za-z0-9]*(\.[A-Za-z0-9]+)*\.sol$' ;;
    tsx)  check "$file" '^[A-Z][A-Za-z0-9]*\.tsx$' ;;
    ts)   if [[ "$base" == use* ]]; then
            check "$file" '^use[A-Z][A-Za-z0-9]*\.ts$'
          else
            check "$file" '^[a-z0-9]+(-[a-z0-9]+)*\.ts$'
          fi ;;
    md)   check "$file" '^[A-Z][A-Z0-9_]*\.md$' ;;
  esac

  if printf '%s' "$file" | LC_ALL=C grep -q '[^ -~]'; then
    echo "naming: non-ASCII path '$file'" >&2
    fail=1
  fi
done < <(find . -type f -not -path './.git/*' -not -path '*/node_modules/*' -print0)

exit "$fail"
```

Se ejecuta en CI y en el hook local:

```bash
./scripts/check-file-names.sh
```

### 7.4 `cspell`

Diccionario inglés por defecto y lista blanca solo para términos españoles de la documentación (por ejemplo `preproducción`). Los identificadores no se añaden a la lista blanca: si no son inglés, se corrigen.

---

## 8. Checklist de PR

- [ ] Archivos y carpetas en inglés, ASCII y con la convención de §1.
- [ ] Identificadores, comentarios y mensajes de error de código en inglés.
- [ ] Documentación en español con nombre de archivo en inglés.
- [ ] Variables de entorno en `UPPER_SNAKE_CASE` y documentadas en `.env.example`.
- [ ] Ningún secreto con prefijo `NEXT_PUBLIC_`.
- [ ] `make lint` y `scripts/check-file-names.sh` en verde.
- [ ] Textos de UI en español y claves i18n en inglés.
