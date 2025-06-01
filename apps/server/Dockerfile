FROM node:20-alpine AS base

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copy workspace files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/server/package.json ./apps/server/
COPY packages ./packages

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy server source
COPY apps/server ./apps/server

# Build stage
FROM base AS build
WORKDIR /app/apps/server
RUN pnpm build

# Production stage
FROM node:20-alpine AS production

RUN npm install -g pnpm

WORKDIR /app

# Copy workspace files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/server/package.json ./apps/server/
COPY packages ./packages

# Install prod dependencies
RUN pnpm install --frozen-lockfile --prod

# Copy built app
COPY --from=build /app/apps/server/dist ./apps/server/dist

# Create logs directory
RUN mkdir -p /app/logs

# Security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001
RUN chown -R nestjs:nodejs /app
USER nestjs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "apps/server/dist/main.js"]
