# Multi-stage build for optimization
FROM node:18-alpine AS builder

# Install dependencies for building
WORKDIR /app
COPY src/package*.json ./
# Use npm install if package-lock.json doesn't exist, otherwise use npm ci
RUN if [ -f "package-lock.json" ]; then \
        npm ci --omit=dev; \
    else \
        npm install --omit=dev; \
    fi

# Production stage
FROM node:18-alpine

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user (check if group exists first)
RUN addgroup -g 1001 -S nodejs 2>/dev/null || true && \
    adduser -S -u 1001 -G nodejs nodejs 2>/dev/null || true

# Set working directory
WORKDIR /app

# Copy dependencies from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy application code
COPY --chown=nodejs:nodejs src/ ./

# Use non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Set environment defaults
ENV NODE_ENV=production \
    PORT=3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["node", "app.js"]