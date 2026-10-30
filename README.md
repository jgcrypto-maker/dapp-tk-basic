# dapp-tk-basic

Prototipo de DApp sobre **Polygon** para:

1. **Comprar** un token ERC-20 pagando con **POL** (token nativo de Polygon).
2. **Consultar** el estado de la venta y cuántos tokens se han distribuido entre wallets.

> **Estado actual: Fase 0 cerrada — arquitectura y entorno verificados.** No hay contratos
> ni frontend todavía. La especificación está en [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
> y el host medido en [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md).

## Idea en una frase

Un contrato `TokenSale` custodia el inventario del token, lo vende a precio fijo en POL y
mantiene la contabilidad on-chain (vendido, restante, recaudado, compradores). Una dApp
Next.js + wagmi/viem lee ese estado por RPC y firma las compras con la wallet del usuario,
sin backend propio y sin custodiar claves.

## Docker-first

El proyecto está diseñado para que **el host solo necesite Docker + el plugin Docker Compose**:
Foundry, Node/pnpm, Anvil, Caddy y PostgreSQL se ejecutan en contenedores con versiones
fijadas. El mismo stack se reproduce en el VPS de PRE (Polygon Amoy) y de PRO (Polygon
mainnet), con un proyecto Compose independiente por entorno y un reverse proxy Caddy
compartido.

El host de desarrollo está medido y documentado en [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md):
macOS 26.7.1 sobre Apple M1, Docker Engine 29.9.1, Compose 5.6.0, buildx 0.38.0, 8 GiB para
la VM de Docker y 44 GiB libres. No hay Node, Foundry ni Caddy instalados en el host, y no
deben instalarse.

| Entorno | Compose | Cadena | Web |
|---|---|---|---|
| DEV | `compose.yaml` + `compose.dev.yaml` | Anvil `31337` | `next dev` |
| PRE | `compose.yaml` + `compose.pre.yaml` | Amoy `80002` | imagen `web:pre` |
| PRO | `compose.yaml` + `compose.pro.yaml` | Polygon `137` | imagen `web:pro` |

## Documentación

| Documento | Contenido |
|---|---|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Alcance revisado, decisiones, modelo de contrato, flujos, seguridad, Docker/entornos y plan por fases |
| [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md) | Host de desarrollo verificado: hardware, versiones de Docker/Compose, toolchain, red, límites y checklist previo a la Fase 1 |
| [`docs/NAMING.md`](docs/NAMING.md) | Convenciones: archivos y código en inglés, documentación en español, aplicación automática en CI |

## Siguiente paso

El entorno local ya está verificado y limpio (0 contenedores, puertos `3000`/`8545` libres).
Queda cerrar las decisiones abiertas de la §15 (o aceptar los valores por defecto, con D15
ya actualizado a las versiones reales) y arrancar la **Fase 1**: toolchain Docker
(`compose.*`, `Dockerfile`s, Makefile compatible con `make` 3.81 y CI base) con un “hola
mundo” de la web y `forge test` ejecutándose en contenedor.
