# dapp-tk-basic

Prototipo de DApp sobre **Polygon** para:

1. **Comprar** un token ERC-20 pagando con **POL** (token nativo de Polygon).
2. **Consultar** el estado de la venta y cuántos tokens se han distribuido entre wallets.

> **Estado actual: Fase 1 completada — toolchain Docker.** Anvil, Next.js y Foundry
> arrancan y se prueban en contenedores; todavía no hay contratos de venta ni dashboard.
> La especificación está en [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) y el host medido
> en [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md).

## Idea en una frase

Un contrato `TokenSale` custodia el inventario del token, lo vende a precio fijo en POL y
mantiene la contabilidad on-chain (vendido, restante, recaudado, compradores). Una dApp
Next.js + wagmi/viem lee ese estado por RPC y firma las compras con la wallet del usuario,
sin backend propio y sin custodiar claves.

## Arranque rápido

Requisitos: **Docker + el plugin Docker Compose**. Nada más se instala en el host.

```bash
make doctor   # Docker, versiones y puertos 3000/8545
make up       # Anvil + Next.js con hot reload, en segundo plano
make test     # forge test dentro del contenedor de contratos
make down     # parar el stack
```

| URL | Servicio |
|---|---|
| <http://127.0.0.1:3000> | dApp (hola mundo + `/api/health`) |
| <http://127.0.0.1:8545> | Anvil, `chainId 31337` |

`make help` lista el resto de objetivos: `dev` (primer plano), `logs`, `ps`, `fmt`,
`fmt-check`, `build-web`, `build-contracts` y `clean`.

## Estructura

```
compose.yaml            # base común (red, healthchecks)
compose.dev.yaml        # Anvil + Next.js con hot reload
compose.tools.yaml      # trabajos one-shot: forge test/fmt (perfil tools)
Makefile                # interfaz única; compatible con GNU Make 3.81
contracts/              # Foundry: Dockerfile, foundry.toml, smoke test y test de toolchain
web/                    # Next.js 15 + TypeScript: hola mundo y /api/health
deployments/            # direcciones por chainId (se llena en fase 2)
docs/                   # ARCHITECTURE, ENVIRONMENT y NAMING
scripts/                # check-file-names.sh
.github/workflows/ci.yml
```

## Docker-first

Foundry, Node/pnpm, Anvil, Caddy y PostgreSQL se ejecutan en contenedores con versiones
fijadas. El mismo stack se reproduce en el VPS de PRE (Polygon Amoy) y de PRO (Polygon
mainnet), con un proyecto Compose independiente por entorno y un reverse proxy Caddy
compartido.

Versiones fijadas: Foundry `v1.5.1`, Node 22 (`22.23.4`), pnpm `12.16.1`, Next.js
`15.5.28`. Las imágenes base se referencian por digest en los `Dockerfile` y en el
`Makefile`.

| Entorno | Compose | Cadena | Web |
|---|---|---|---|
| DEV | `compose.yaml` + `compose.dev.yaml` | Anvil `31337` | `next dev` |
| PRE | `compose.yaml` + `compose.pre.yaml` (fase 5) | Amoy `80002` | imagen `web:pre` |
| PRO | `compose.yaml` + `compose.pro.yaml` (fase 5) | Polygon `137` | imagen `web:pro` |

## Documentación

| Documento | Contenido |
|---|---|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Alcance revisado, decisiones, modelo de contrato, flujos, seguridad, Docker/entornos y plan por fases |
| [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md) | Host de desarrollo verificado: hardware, versiones de Docker/Compose, toolchain, red, límites y checklist previo a la Fase 1 |
| [`docs/NAMING.md`](docs/NAMING.md) | Convenciones: archivos y código en inglés, documentación en español, aplicación automática en CI |

## Siguiente paso

**Fase 2 — contratos**: `SaleToken` y `TokenSale` con OpenZeppelin 5.x, tests unitarios,
fuzz e invariantes, y despliegue reproducible en Amoy. El smoke test y `Smoke.sol` se
sustituyen por los contratos reales.
