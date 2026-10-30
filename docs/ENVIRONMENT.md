# Entorno local verificado

| | |
|---|---|
| **Versión** | 1.0 |
| **Fecha de medición** | 2026-10-30 |
| **Máquina** | MacBook Pro (Apple M1), macOS 26.7.1 |
| **Alcance** | Host de desarrollo (DEV). PRE y PRO se ejecutan en VPS Linux (§8.10 de [`ARCHITECTURE.md`](ARCHITECTURE.md)) |
| **Conclusión** | El host cumple el ADR-11 (Docker-first) y está **listo para la Fase 1** sin instalar nada más |

Este documento sustituye a cualquier suposición sobre el entorno: recoge lo que se midió, las restricciones que impone y cómo volver a comprobarlo. La arquitectura sigue siendo la fuente de verdad del diseño; aquí solo se documenta el sustrato donde se ejecuta.

---

## 1. Resumen

- El host solo tiene **Docker + Docker Compose + buildx**, más las utilidades del sistema (`git`, `make`, `jq`, `curl`). **No** hay Node, pnpm, Foundry, Anvil, Caddy ni PostgreSQL instalados, y no deben instalarse: viven en contenedores.
- El motor arrancó con residuos de un prototipo anterior (proyecto Compose huérfano `dapp-basic-tk`, levantado desde una ruta ya borrada) que ocupaba los puertos `3000` y `8545`. Se limpió por completo (§6).
- Estado actual del motor: **0 contenedores, 0 imágenes, 0 volúmenes, 0 caché de build**. Puertos `3000` y `8545` libres.
- La versión real de Compose es **v5.6.0**, no la "v2" que citaba la v0.2 de la arquitectura. `make` es **3.81** (el de Apple), no 4.x.

---

## 2. Hardware y sistema

| Elemento | Medición |
|---|---|
| Modelo | MacBook Pro (Apple M1, `T8103`), `arm64` |
| Sistema | macOS 26.7.1, build `25G241`, kernel Darwin 25.6.0 |
| CPU | 8 núcleos |
| RAM del host | 16 GiB |
| Disco | 228 GiB · **44 GiB libres (78 % usado)** tras la limpieza |
| Shell | `/bin/zsh` |
| Usuario | `josegalindoegea` |

> El margen de disco es el recurso más ajustado del host. Con el stack completo construido (web + contratos + caché de build) se consumen varios GiB; conviene no acumular tags de imagen ni cachés de build (§7).

---

## 3. Docker

| Componente | Versión medida |
|---|---|
| Docker Desktop | 4.96.0 |
| Docker Engine (servidor) | 29.9.1, build `dfc520d` |
| Docker Compose (plugin) | **v5.6.0** |
| buildx | v0.38.0 |
| BuildKit | v0.34.0 |
| Contexto activo | `desktop-linux` (`unix:///Users/josegalindoegea/.docker/run/docker.sock`) |
| Driver de almacenamiento | `overlayfs` |
| VM de Docker | 8 vCPU · 8 GiB RAM (≈50 % de la RAM del host) |
| Rosetta | Activa (permite ejecutar `linux/amd64` en Apple Silicon) |
| Plataformas de build | `linux/amd64`, `linux/arm64`, `linux/ppc64le`, `linux/s390x` (+2) |

Plugins de cliente disponibles: `buildx`, `compose`, `scout`, `debug`, `desktop`, `mcp`, `sandbox`, entre otros. Relevantes para el proyecto: **buildx** (builds multi-arch) y **scout** (escaneo de CVEs de las imágenes, útil antes de PRE).

---

## 4. Toolchain del host

| Herramienta | Estado | Versión |
|---|---|---|
| `git` | ✔ | 2.50.1 (Apple Git-155) |
| `make` | ✔ | **GNU Make 3.81** |
| `jq` | ✔ | sistema |
| `curl` | ✔ | 8.7.1 |
| `dig`, `openssl` | ✔ | sistema |
| `node`, `npm`, `pnpm`, `corepack` | ✘ ausentes | — |
| `forge`, `cast`, `anvil` | ✘ ausentes | — |
| `caddy`, `psql` | ✘ ausentes | — |
| `brew` | ✘ ausente | — |

La ausencia de toolchain de desarrollo es **el estado deseado** (ADR-11). Si algún día se instala algo en el host, hay que justificarlo como excepción consciente en §8.11 de la arquitectura.

---

## 5. Red y acceso

| Comprobación | Resultado |
|---|---|
| `https://ghcr.io/v2/` | HTTP `401` en 0,35 s (esperado sin token: el registro responde) |
| `https://registry-1.docker.io/v2/` | HTTP `401` en 0,38 s (esperado) |
| SSH a `git@github-galindoit` | Autentica como `josegalindo-it` |
| Remoto del repo | `git@github-galindoit:josegalindo-it/dapp-tk-basic.git` |
| Puertos `80`, `443`, `5432`, `8080` | Libres |
| Puertos `3000`, `8545` | Libres tras la limpieza |

El acceso a GHCR y a Docker Hub funciona sin configuración adicional. El `docker login` a GHCR solo hará falta para **publicar** imágenes (Fase 5), no para consumir imágenes públicas.

---

## 6. Limpieza ejecutada (2026-10-30)

**Situación encontrada.** El proyecto Compose `dapp-basic-tk` seguía en ejecución con 2 contenedores levantados 24 h antes desde `/Users/josegalindoegea/code-hub/archived/03_PROJECTS/dapp-basic-tk`, una ruta que ya no existe. Ese proyecto no tiene relación con este repositorio: era un prototipo previo con el mismo stack (Anvil + web en Next.js).

| Recurso | Detalle |
|---|---|
| Contenedores | `dapp-basic-tk-anvil-1` (healthy, `127.0.0.1:8545`) y `dapp-basic-tk-web-dev-1` (`127.0.0.1:3000`) |
| Imágenes | `dapp-basic-tk-web:3c2e629`, `dapp-basic-tk-web:d7774d4`, `dapp-basic-tk-tools:dev` (916 MB), `node:22-bookworm-slim`, `caddy:2-alpine`, `hello-world` |
| Volúmenes | `dapp-basic-tk_foundry-cache`, `dapp-basic-tk_npm-cache`, `dapp-basic-tk_web-node-modules` (solo cachés, sin datos) |
| Red | `dapp-basic-tk_default` |
| Caché de build | 54 objetos, 3,8 GB |

**Acciones.** Parada y borrado de los 2 contenedores, `docker system prune -a --volumes` y borrado explícito de los 3 volúmenes restantes.

**Resultado.** 4,88 GB recuperados por el prune + 887 MB de volúmenes; el disco libre pasó de **40 GB a 44 GB**. Motor vacío y puertos liberados. No se perdió nada del repositorio actual, que solo contiene documentación.

> Lección aplicable a la Fase 1: definir `name:` y etiquetas de proyecto Compose desde el primer commit, y usar `docker compose -p <proyecto> down --volumes` al cambiar de rama o de prototipo, para no dejar contenedores huérfanos consumiendo puertos.

---

## 7. Restricciones operativas derivadas

| Restricción | Consecuencia práctica |
|---|---|
| **`make` 3.81** | Nada de `--output-sync`, `.ONESHELL`, `$(file …)` ni asignación `!=`. El `Makefile` de la Fase 1 debe ser compatible con 3.81 (o ejecutarse dentro de un contenedor con `make` moderno). |
| **VM Docker de 8 GiB** | `pnpm install` + `next build` + `forge build` en paralelo pueden agotar memoria. Limitar la concurrencia en CI local y en `make` (un build pesado a la vez). |
| **44 GiB libres** | Mantener una sola etiqueta por imagen y ejecutar `docker builder prune` tras cambios grandes de dependencias. El objetivo es no bajar de ~20 GiB libres. |
| **ARM64 con Rosetta** | `linux/amd64` funciona por emulación, pero es 2–5× más lento: úsese solo para verificar paridad, no como build por defecto. `linux/arm64` es el camino nativo en DEV. |
| **BuildKit 0.34** | Soporta `# syntax=docker/dockerfile:1.7`, `--mount=type=cache` y `buildx build --platform`. No hay que añadir *features* más nuevas sin comprobar el soporte. |
| **Sin `brew`** | Cualquier utilidad extra del host se instala con instalador oficial o se evita; preferible resolverlo en contenedor. |
| **`NEXT_PUBLIC_*` incrustadas en build** | En DEV no afecta; en PRE/PRO obliga a dos builds del mismo commit (matriz de CI), como ya recoge §8.5. |

---

## 8. Checklist previo a la Fase 1

Ejecutar antes de dar por buena la Fase 1 en esta máquina:

```bash
docker version --format 'engine={{.Server.Version}}'
docker compose version
docker buildx version
docker info --format 'cpus={{.NCPU}} mem={{.MemTotal}} driver={{.Driver}}'
docker compose ls -a            # debe estar vacío
lsof -nP -iTCP:3000 -sTCP:LISTEN # sin salida
lsof -nP -iTCP:8545 -sTCP:LISTEN # sin salida
df -h /System/Volumes/Data | tail -1
```

Criterios de aceptación del entorno:

1. `docker info` responde y el contexto es `desktop-linux`.
2. `docker compose ls -a` no muestra proyectos ajenos.
3. `3000` y `8545` libres.
4. ≥ 20 GiB libres en disco.
5. Rosetta activa si se va a probar `linux/amd64`.

---

## 9. Cómo volver a medir

```bash
sw_vers && uname -m
sysctl -n hw.ncpu hw.memsize
docker --version && docker compose version && docker buildx version
docker info --format '{{.ServerVersion}} {{.NCPU}} {{.MemTotal}} {{.Driver}}'
docker system df
df -h /System/Volumes/Data | tail -1
```

Registrar el resultado aquí con una fila nueva en el historial (§10) cuando cambie algo relevante: versión mayor de Docker, actualización de macOS, cambio de máquina o ampliación de disco.

---

## 10. Historial

| Fecha | Cambio |
|---|---|
| 2026-10-30 | Medición inicial del host, limpieza del proyecto huérfano `dapp-basic-tk` y verificación de que no hay toolchain de desarrollo instalado. |
