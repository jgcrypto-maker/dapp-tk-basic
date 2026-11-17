# Changelog

Todos los cambios relevantes del proyecto se documentan en este archivo.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y
el versionado [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased]

### Changed

- Modelo on-chain revisado tras comparar con el prototipo predecesor: el `TokenSale` crea su
  propio `SaleToken` en el constructor y reparte inventario/tesorería (ADR-02 y ADR-14);
  precio y ventana pasan a ser **inmutables** (ADR-03); `quote` redondea al alza;
  `getBuyers` limita a 100 entradas por página; se añaden contadores de retiradas y barridos.
- `buyFor` aplazado (D16): la compra es siempre para `msg.sender`.
- Web: exportación estática con configuración en tiempo de ejecución (ADR-15, D17),
  pendiente de implementar en la fase 3.

### Added

- **Fase 2:** `SaleToken` y `TokenSale` con OpenZeppelin 5.7.0 y forge-std 1.9.7
  (submodules y `foundry.lock`), 38 tests unitarios/fuzz/invariantes, `Deploy.s.sol`,
  `deployments/dev.json`, `make deploy-local`/`check-local`/`e2e`, imagen de contratos
  con UID/GID del host y job E2E en CI.
- **Fase 3:** dashboard estático (Next `output: "export"`) con viem, configuración en runtime
  (`/config.json`, `/deployment.json`), consulta por wallet en `/wallet?address=`, imagen
  Caddy con cabeceras de seguridad y healthcheck en `/config.json`.

### Changed

- La imagen web pasa de Next standalone (Node en runtime) a export estático servido por Caddy.

## [0.1.0] - 2026-10-30

Primera entrega: arquitectura cerrada y toolchain reproducible en contenedores.

### Added

- Arquitectura completa en `docs/ARCHITECTURE.md` (v0.5): alcance, 13 ADRs, modelo
  on-chain, seguridad, Docker-first y plan por fases.
- Decisiones D1–D15 cerradas: precio 0,01 POL/TK con tope 0,05; límites de
  1.000/100.000 TK por wallet; ventana de 30 días; Amoy como red de pruebas.
- `compose.yaml`, `compose.dev.yaml` y `compose.tools.yaml` con Anvil, Next.js y
  trabajos one-shot de Foundry.
- Imágenes fijadas por digest: Foundry `v1.5.1` y Node 22 (`22.23.4`).
- Web Next.js 15 con página de estado, `/api/health` y salida `standalone`.
- `Makefile` compatible con GNU Make 3.81 y CI base (nombres, Compose, contratos, web).
- Documentación de entorno (`docs/ENVIRONMENT.md`) y convenciones (`docs/NAMING.md`).

### Changed

- Limpieza de un proyecto Compose huérfano que ocupaba los puertos 3000 y 8545.
- Ruido de buildx contenido en `.buildx/` dentro del repositorio.

[Unreleased]: https://github.com/jgcrypto-maker/dapp-tk-basic/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/jgcrypto-maker/dapp-tk-basic/releases/tag/v0.1.0
