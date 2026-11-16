# Documentación

Índice de la documentación del proyecto. El contenido se redacta en español y los
nombres de archivo en inglés, según [`NAMING.md`](NAMING.md).

| Documento | Qué contiene | Cuándo actualizarlo |
|---|---|---|
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Alcance, decisiones (ADR-01…ADR-13), modelo on-chain, reglas de `buy`, seguridad, Docker/entornos, plan por fases y decisiones cerradas (§15) | Cambios de diseño, nuevos ADR o cierre de decisiones |
| [`ENVIRONMENT.md`](ENVIRONMENT.md) | Host de desarrollo medido: hardware, Docker/Compose, toolchain, red, límites y checklist | Cambios de máquina, versiones mayores o de disco |
| [`NAMING.md`](NAMING.md) | Convenciones de nombres y su aplicación automática en CI | Nuevas excepciones o reglas |
| [`../CHANGELOG.md`](../CHANGELOG.md) | Historial de versiones | Cada entrega de fase o release |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Flujo de trabajo, commits y checklist de PR | Cambios en el proceso |
| [`../SECURITY.md`](../SECURITY.md) | Reporte de vulnerabilidades y alcance | Cambios en el modelo de seguridad |

## Cómo se mantiene

1. **Una sola fuente de verdad por tema:** el diseño vive en `ARCHITECTURE.md`, no
   se duplica en issues ni en el README.
2. **Los enlaces internos se verifican en CI** (`scripts/check-links.sh`), así que
   mover un documento exige actualizar sus referencias.
3. **Los cambios de documentación van en commits `docs:`** separados de los de
   código cuando sea posible.
4. **Las decisiones nuevas** se añaden como ADR en la §2 de `ARCHITECTURE.md` y,
   si afectan al alcance, se registran en el `CHANGELOG.md`.

## Documentación pendiente

| Documento | Fase |
|---|---|
| `DEPLOYMENT.md` (runbook de Amoy y mainnet) | 2 y 5 |
| `OPERATIONS.md` (VPS, backups, monitorización) | 5 |
| `TESTING.md` (estrategia de tests y cobertura) | 2 |
