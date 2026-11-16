# Cómo contribuir

Gracias por el interés. Este documento resume el flujo de trabajo y los
estándares del repositorio. Las reglas de nombres están en
[`docs/NAMING.md`](docs/NAMING.md) y las decisiones de diseño en
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Requisitos

- **Docker + plugin Docker Compose** (el host no necesita Node, Foundry ni Caddy).
- `make` (3.81 o superior) y `git`.
- `python3` solo para las comprobaciones de documentación.

Comprueba el entorno antes de empezar:

```bash
make doctor
```

## Puesta en marcha

```bash
make env     # crea .env.dev desde .env.example
make up      # Anvil (8545) + Next.js (3000)
make test    # forge test en contenedor
make down
```

`make help` lista todos los objetivos disponibles.

## Flujo de trabajo

1. Abre una **issue** describiendo el problema o la propuesta (las plantillas
   están en `.github/ISSUE_TEMPLATE/`).
2. Crea una rama desde `main` con el prefijo adecuado:
   - `feat/…` nueva funcionalidad
   - `fix/…` corrección de un fallo
   - `docs/…` documentación
   - `chore/…` tooling, dependencias o CI
   - `refactor/…` cambio sin alterar comportamiento
3. Haz commits pequeños y atómicos.
4. Ejecuta `make check` y `make test`.
5. Abre la pull request rellenando la plantilla y enlazando la issue.

## Commits

Se usa [Conventional Commits](https://www.conventionalcommits.org/) en inglés:

```
feat(contracts): add TokenSale buy flow
fix(web): handle missing sale address
docs: record verified host environment
chore(ci): cache pnpm store
```

Tipos admitidos: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`,
`build`, `perf`. Ámbitos habituales: `contracts`, `web`, `docker`, `ci`,
`docs`.

## Estándares de código

- **Código y nombres en inglés; documentación y textos de UI en español.**
  Detalle en [`docs/NAMING.md`](docs/NAMING.md).
- Solidity: `forge fmt` antes de commitear (lo comprueba `make fmt-check`).
- TypeScript: `pnpm typecheck` y `pnpm build` deben pasar.
- No se aceptan secretos, claves privadas ni direcciones de producción en el
  repositorio. Usa `.env.example` como plantilla.

## Comprobaciones antes de la PR

```bash
make check   # nombres, enlaces, compose y formato Solidity
make test    # tests de contratos en contenedor
```

La CI ejecuta además typecheck y build de la web, y construye las imágenes.

## Checklist de la pull request

- [ ] El cambio está descrito y enlaza la issue correspondiente.
- [ ] `make check` y `make test` pasan en local.
- [ ] Se actualizó la documentación afectada (y `CHANGELOG.md` si aplica).
- [ ] No hay secretos, rutas absolutas ni artefactos de build.
- [ ] Los nombres siguen `docs/NAMING.md`.
