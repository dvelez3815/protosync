FROM node:20-alpine AS base

RUN npm install -g pnpm

WORKDIR /app

# Copy workspace files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/web/package.json ./apps/web/
COPY packages ./packages

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy web source
COPY apps/web ./apps/web

# Build stage
FROM base AS build
WORKDIR /app/apps/web
RUN pnpm build

# Production stage
FROM node:20-alpine AS production

RUN npm install -g pnpm

WORKDIR /app

# Copy workspace files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/web/package.json ./apps/web/
COPY packages ./packages

# Install prod dependencies
RUN pnpm install --frozen-lockfile --prod

# Copy built app
COPY --from=build /app/apps/web/dist ./apps/web/dist

# Security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S astro -u 1001
RUN chown -R astro:nodejs /app
USER astro

EXPOSE 4321

CMD ["node", "apps/web/dist/server/entry.mjs"]
