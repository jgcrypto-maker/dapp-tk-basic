## Resumen

<!-- Qué cambia y por qué. Enlaza la issue: Closes #123 -->

## Tipo de cambio

- [ ] `feat` — nueva funcionalidad
- [ ] `fix` — corrección de un fallo
- [ ] `docs` — solo documentación
- [ ] `refactor` — cambio interno sin alterar comportamiento
- [ ] `chore` / `ci` / `build` — tooling, dependencias o pipeline

## Ámbito

- [ ] `contracts` (Solidity)
- [ ] `web` (Next.js)
- [ ] `docker` / `compose`
- [ ] `ci`
- [ ] `docs`

## Cómo se ha probado

<!-- Comandos ejecutados y resultado. Ej.: make check, make test, pnpm build -->

```text

```

## Checklist

- [ ] `make check` pasa en local.
- [ ] `make test` pasa (contratos) y, si toca la web, `pnpm typecheck` y `pnpm build`.
- [ ] Documentación actualizada (`docs/`, `CHANGELOG.md` si aplica).
- [ ] Sin secretos, claves privadas ni `.env` reales en el diff.
- [ ] Nombres conformes con `docs/NAMING.md`.
- [ ] Si cambia el comportamiento on-chain, se revisó la §7.4 de `docs/ARCHITECTURE.md`.

## Notas para la revisión

<!-- Riesgos, decisiones tomadas, capturas o enlaces relevantes -->
