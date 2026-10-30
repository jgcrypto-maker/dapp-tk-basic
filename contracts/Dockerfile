# syntax=docker/dockerfile:1.7
# Contracts image: official Foundry image pinned by digest (linux/amd64 + linux/arm64).
ARG FOUNDRY_VERSION=v1.5.1@sha256:3a70bfa9bd2c732a767bb60d12c8770b40e8f9b6cca28efc4b12b1be81c7f28e
FROM ghcr.io/foundry-rs/foundry:${FOUNDRY_VERSION}

# The official image already ships a non-root `foundry` user (uid 1000).
# `.svm` must exist and belong to that user: a named volume inherits its ownership,
# otherwise forge cannot cache solc downloads and fails with "Permission denied".
USER root
RUN mkdir -p /app /home/foundry/.svm && chown -R foundry:foundry /app /home/foundry
USER foundry

ENV SVM_HOME=/home/foundry/.svm
WORKDIR /app

# `forge` is the entry point so `docker compose run contracts test` reads naturally.
ENTRYPOINT ["forge"]
CMD ["--version"]
