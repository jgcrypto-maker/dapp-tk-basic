# Changelog

Todos los cambios relevantes del proyecto se documentan en este archivo.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y
el versionado [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased]

### Added

- **Fase 2 (pendiente):** `SaleToken`, `TokenSale`, tests unitarios/fuzz/invariantes,
  script de despliegue y `deployments/80002.json` en Polygon Amoy.

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

[Unreleased]: https://github.com/josegalindo-it/dapp-tk-basic/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/josegalindo-it/dapp-tk-basic/releases/tag/v0.1.0
