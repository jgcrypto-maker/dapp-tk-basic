# dapp-tk-basic

[![CI](https://github.com/jgcrypto-maker/dapp-tk-basic/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/jgcrypto-maker/dapp-tk-basic/actions/workflows/ci.yml)
[![Estado](https://img.shields.io/badge/estado-fase%202%20%C2%B7%20contratos-blue)](#estado)
[![Red](https://img.shields.io/badge/red-Polygon%20Amoy%2080002-8247e5)](https://amoy.polygonscan.com)
[![Licencia](https://img.shields.io/badge/licencia-propietaria-lightgrey)](LICENSE)

Prototipo de DApp sobre **Polygon** para vender un token **ERC-20** a precio fijo en **POL**
y consultar el estado de la venta: tokens vendidos, restantes, POL recaudado y detalle por
wallet.

Un contrato `TokenSale` custodia el inventario, aplica precio y límites on-chain y mantiene
toda la contabilidad. La dApp Next.js lee ese estado por RPC y firma las compras con la
wallet del usuario: sin backend propio, sin custodia de claves y sin confiar en el cliente
para el precio.

> **Repositorio privado y propietario.** Consulta [`LICENSE`](LICENSE). No se concede
> licencia de uso, copia ni distribución.

## Estado

| Fase | Estado | Entrega |
|---|---|---|
| 0 · Arquitectura | ✅ Cerrada | [ARCHITECTURE.md](docs/ARCHITECTURE.md) v0.7 y decisiones §15 cerradas |
| 1 · Toolchain Docker | ✅ Cerrada | Compose, Dockerfiles, Makefile y CI funcionando |
| 2 · Contratos | 🟡 En curso | `SaleToken`, `TokenSale`, 38 tests y despliegue local; broadcast en Amoy pendiente |
| 3 · Dashboard | ⬜ Pendiente | Lectura de estado y consulta por wallet |
| 4 · Compra E2E | ⬜ Pendiente | Formulario, simulación, firma y recibo |
| 5 · PRE/PRO | ⬜ Pendiente | VPS, edge, TLS y pipelines |
| 6 · Extras | ⬜ Pendiente | Indexer, admin, CSV y auditoría |

Detalle de la entrega actual en [`CHANGELOG.md`](CHANGELOG.md).

## Arranque rápido

Único requisito: **Docker + plugin Docker Compose**. Nada más se instala en el host.

```bash
make doctor   # Docker, versiones y puertos 3000/8545
make env      # crea .env.dev desde .env.example
make up       # Anvil + Next.js con hot reload, en segundo plano
make test     # forge test en el contenedor de contratos
make e2e      # Anvil + despliegue de la venta + comprobación on-chain
make check    # nombres, enlaces, Compose y formato
make down     # parar el stack
```

| URL | Servicio |
|---|---|
| <http://127.0.0.1:3000> | dApp (estado + `/api/health`) |
| <http://127.0.0.1:8545> | Anvil, `chainId 31337` |

`make help` lista el resto de objetivos.

## Estructura

```text
├── compose.yaml             # base: red interna, healthchecks, nombre de proyecto
├── compose.dev.yaml         # DEV: Anvil + Next.js con hot reload
├── compose.tools.yaml       # one-shot: forge test/fmt, despliegue y checks
├── Makefile                 # interfaz única, compatible con GNU Make 3.81
├── contracts/               # Foundry: src/{SaleToken,TokenSale}.sol, test/, script/Deploy.s.sol
├── web/                     # Next.js 15 + TypeScript (App Router)
├── deployments/             # dev.json y, por entorno, <chainId>.json
├── docs/                    # ARCHITECTURE, ENVIRONMENT, NAMING e índice
├── scripts/                 # comprobaciones de nombres, enlaces y despliegue local
└── .github/                 # CI, plantillas de issue/PR, CODEOWNERS, Dependabot
```

## Stack y versiones

| Componente | Versión fijada |
|---|---|
| Contratos | Solidity 0.8.24 · Foundry `v1.5.1` · OpenZeppelin `5.7.0` · forge-std `1.9.7` |
| Web | Next.js `15.5.28` · React `19.3.1` · TypeScript `5.9.3` · pnpm `12.16.1` |
| Runtime | Node 22 (`22.23.4`, imagen por digest) |
| Cadena | Anvil `31337` (DEV) · Polygon Amoy `80002` (pruebas) · Polygon `137` (PRO) |

Todo el toolchain corre en contenedores; el host no necesita Node, Foundry ni Caddy. Los
detalles del entorno medido están en [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md).

## Entornos

| Entorno | Compose | Cadena | Web |
|---|---|---|---|
| DEV | `compose.yaml` + `compose.dev.yaml` | Anvil `31337` | `next dev` |
| PRE | `compose.yaml` + `compose.pre.yaml` (fase 5) | Amoy `80002` | imagen `web:pre` |
| PRO | `compose.yaml` + `compose.pro.yaml` (fase 5) | Polygon `137` | imagen `web:pro` |

## Documentación

| Documento | Contenido |
|---|---|
| [`docs/README.md`](docs/README.md) | Índice y política de mantenimiento de la documentación |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Alcance, ADRs, modelo on-chain, seguridad, Docker y plan por fases |
| [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md) | Host verificado, límites y checklist previo |
| [`docs/NAMING.md`](docs/NAMING.md) | Convenciones de nombres y su aplicación en CI |
| [`CHANGELOG.md`](CHANGELOG.md) | Historial de versiones |

## Contribuir

Lee [`CONTRIBUTING.md`](CONTRIBUTING.md) antes de abrir una PR. Los commits siguen
[Conventional Commits](https://www.conventionalcommits.org/) en inglés y el código se
nombra en inglés; la documentación se escribe en español.

## Seguridad

No abras issues públicas para vulnerabilidades. Usa el canal privado descrito en
[`SECURITY.md`](SECURITY.md). El proyecto no está autorizado para mainnet.

## Licencia

Propietaria, todos los derechos reservados. Ver [`LICENSE`](LICENSE).
