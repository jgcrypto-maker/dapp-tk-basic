# syntax=docker/dockerfile:1.7
# Contracts image: official Foundry image pinned by digest (linux/amd64 + linux/arm64).
ARG FOUNDRY_VERSION=v1.5.1@sha256:3a70bfa9bd2c732a767bb60d12c8770b40e8f9b6cca28efc4b12b1be81c7f28e
FROM ghcr.io/foundry-rs/foundry:${FOUNDRY_VERSION}

# Build with the host UID/GID so files created in bind mounts (out/, cache/, deployments/)
# belong to the developer, not to uid 1000. CI passes the runner's uid/gid.
ARG HOST_UID=1000
ARG HOST_GID=1000

USER root
RUN groupmod -o -g "${HOST_GID}" foundry \
 && usermod -o -u "${HOST_UID}" foundry \
 && mkdir -p /app /workspace /home/foundry/.svm \
 && chown -R "${HOST_UID}:${HOST_GID}" /app /workspace /home/foundry
USER foundry

ENV SVM_HOME=/home/foundry/.svm
WORKDIR /app

# `forge` is the entry point so `docker compose run contracts test` reads naturally.
ENTRYPOINT ["forge"]
CMD ["--version"]
