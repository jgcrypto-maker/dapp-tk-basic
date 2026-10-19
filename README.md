# dapp-tk-basic

Prototipo de DApp sobre **Polygon** para:

1. **Comprar** un token ERC-20 pagando con **POL** (token nativo de Polygon).
2. **Consultar** el estado de la venta y cuántos tokens se han distribuido entre wallets.

> **Estado actual: Fase 0 — arquitectura.** No hay contratos ni frontend todavía.
> La especificación completa está en [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md).

## Idea en una frase

Un contrato `TokenSale` custodia el inventario del token, lo vende a precio fijo en POL y
mantiene la contabilidad on-chain (vendido, restante, recaudado, compradores). Una dApp
Next.js + wagmi/viem lee ese estado por RPC y firma las compras con la wallet del usuario,
sin backend propio y sin custodiar claves.

## Documentación

| Documento | Contenido |
|---|---|
| [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) | Alcance revisado, decisiones, modelo de contrato, flujos, seguridad, despliegue y plan por fases |

## Siguiente paso

Cerrar las decisiones abiertas de la §14 del documento (o aceptar los valores por defecto)
y arrancar la **Fase 1**: contratos `SaleToken` + `TokenSale`, tests con Foundry y despliegue
en Polygon Amoy.
