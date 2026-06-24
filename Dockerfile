# ── Stage 1: install dependencies ─────────────────────────────────────────────
# Using a pinned minor version (not 'latest') so the image is reproducible
FROM node:20.12-alpine AS deps

WORKDIR /app

# Copy manifests first — Docker caches this layer until package.json changes
COPY package*.json ./
RUN npm ci --only=production

# ── Stage 2: production image ──────────────────────────────────────────────────
# Alpine keeps the image small (~50MB vs ~300MB for the full node image)
FROM node:20.12-alpine AS production

# Why this matters for security:
# Running as root inside a container means a process escape = root on the host.
# A dedicated non-root user limits the blast radius.
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only production deps from the build stage (no devDependencies, no test files)
COPY --from=deps /app/node_modules ./node_modules
COPY src/ ./src/
COPY package.json ./

# Switch to the non-root user before the process starts
USER appuser

# Document the port — doesn't publish it, just metadata for tooling
EXPOSE 3000

# Use the array form (exec form) — avoids spawning a shell, signals go
# directly to node (important for graceful ECS task shutdown)
CMD ["node", "src/server.js"]
