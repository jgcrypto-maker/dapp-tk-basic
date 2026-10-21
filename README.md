# dapp-tk-basic

Prototipo de DApp sobre **Polygon** para:

1. **Comprar** un token ERC-20 pagando con **POL** (token nativo de Polygon).
2. **Consultar** el estado de la venta y cuántos tokens se han distribuido entre wallets.

> **Estado actual: Fase 0 — arquitectura.** No hay contratos ni frontend todavía.
> La especificación completa está en [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Idea en una frase

Un contrato `TokenSale` custodia el inventario del token, lo vende a precio fijo en POL y
mantiene la contabilidad on-chain (vendido, restante, recaudado, compradores). Una dApp
Next.js + wagmi/viem lee ese estado por RPC y firma las compras con la wallet del usuario,
sin backend propio y sin custodiar claves.

## Docker-first

El proyecto está diseñado para que **el host solo necesite Docker + Docker Compose v2**:
Foundry, Node/pnpm, Anvil, Caddy y PostgreSQL se ejecutan en contenedores con versiones
fijadas. El mismo stack se reproduce en el VPS de PRE (Polygon Amoy) y de PRO (Polygon
mainnet), con un proyecto Compose independiente por entorno y un reverse proxy Caddy
compartido.

| Entorno | Compose | Cadena | Web |
|---|---|---|---|
| DEV | `compose.yaml` + `compose.dev.yaml` | Anvil `31337` | `next dev` |
| PRE | `compose.yaml` + `compose.pre.yaml` | Amoy `80002` | imagen `web:pre` |
| PRO | `compose.yaml` + `compose.pro.yaml` | Polygon `137` | imagen `web:pro` |

## Documentación

| Documento | Contenido |
|---|---|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Alcance revisado, decisiones, modelo de contrato, flujos, seguridad, Docker/entornos y plan por fases |
| [`docs/NAMING.md`](docs/NAMING.md) | Convenciones: archivos y código en inglés, documentación en español, aplicación automática en CI |

## Siguiente paso

Cerrar las decisiones abiertas de la §15 del documento (o aceptar los valores por defecto)
y arrancar la **Fase 1**: toolchain Docker (`compose.*`, `Dockerfile`s, Makefile y CI base)
con un “hola mundo” de la web y `forge test` ejecutándose en contenedor.
