# syntax=docker/dockerfile:1.7
# Web image: multi-stage (base → deps → dev / builder → runner).
# Pin NODE_IMAGE to a digest for reproducible builds (see docs/ENVIRONMENT.md).

ARG NODE_IMAGE=node:22-alpine@sha256:fe4f6d74e20370acb04ad889077d14d0f64a9c8ea6a42bc60cddf1e844699914

FROM ${NODE_IMAGE} AS base
ENV NEXT_TELEMETRY_DISABLED=1
RUN corepack enable && corepack prepare pnpm@12.16.1 --activate
WORKDIR /app

FROM base AS deps
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Development target: hot reload with the source bind-mounted by compose.dev.yaml.
FROM deps AS dev
ENV NODE_ENV=development
COPY . .
EXPOSE 3000
CMD ["pnpm", "dev"]

FROM base AS builder
ARG NEXT_PUBLIC_CHAIN_ID=31337
ARG NEXT_PUBLIC_RPC_URL=http://127.0.0.1:8545
ARG NEXT_PUBLIC_SALE_ADDRESS=0x0000000000000000000000000000000000000000
ARG NEXT_PUBLIC_TOKEN_ADDRESS=0x0000000000000000000000000000000000000000
ENV NEXT_PUBLIC_CHAIN_ID=${NEXT_PUBLIC_CHAIN_ID} \
    NEXT_PUBLIC_RPC_URL=${NEXT_PUBLIC_RPC_URL} \
    NEXT_PUBLIC_SALE_ADDRESS=${NEXT_PUBLIC_SALE_ADDRESS} \
    NEXT_PUBLIC_TOKEN_ADDRESS=${NEXT_PUBLIC_TOKEN_ADDRESS}
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm build

FROM base AS runner
ENV NODE_ENV=production
RUN addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY --from=builder --chown=app:app /app/.next/standalone ./
COPY --from=builder --chown=app:app /app/.next/static ./.next/static
COPY --from=builder --chown=app:app /app/public ./public
USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --retries=3 --start-period=20s \
    CMD wget -qO- http://127.0.0.1:3000/api/health || exit 1
CMD ["node", "server.js"]
