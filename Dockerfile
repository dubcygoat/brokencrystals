FROM node:18-alpine AS build

WORKDIR /usr/src/app

# Copy necessary files
COPY --chown=node:node package*.json ./
COPY --chown=node:node tsconfig.build.json ./
COPY --chown=node:node tsconfig.json ./
COPY --chown=node:node nest-cli.fast.json ./
COPY --chown=node:node .env ./
COPY --chown=node:node config ./config
COPY --chown=node:node keycloak ./keycloak
COPY --chown=node:node src ./src

# Set npm cache, DNS, and install dependencies
ENV NPM_CONFIG_LOGLEVEL=verbose
RUN npm ci --no-audit
#RUN npm cache verify

# Build the server
RUN npm run build
RUN npm prune --production


# Create client directory and copy client project files
RUN mkdir -p ./client
COPY --chown=node:node client/package*.json ./client/
COPY --chown=node:node client/src ./client/src
COPY --chown=node:node client/public ./client/public
COPY --chown=node:node client/typings ./client/typings
COPY --chown=node:node client/vcs ./client/vcs
COPY --chown=node:node client/tsconfig.json ./client/tsconfig.json
COPY --chown=node:node client/vite.config.ts ./client/vite.config.ts
COPY --chown=node:node client/index.html ./client/index.html

# Avoid Cypress binary installation for headless CI/CD
ENV CYPRESS_INSTALL_BINARY=0

# Install and build client dependencies
RUN npm ci --prefix=client --no-audit
RUN npm run build --prefix=client

# Switch to non-root user
USER node

###################
# PRODUCTION
###################

FROM node:18-alpine AS production

WORKDIR /usr/src/app

# Copy environment variables and configurations
COPY --chown=node:node .env ./
COPY --chown=node:node config ./config
COPY --chown=node:node keycloak ./keycloak

# Copy production dependencies and build artifacts from build stage
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/package*.json ./
COPY --chown=node:node --from=build /usr/src/app/dist ./dist
COPY --chown=node:node --from=build /usr/src/app/client/dist ./client/dist
COPY --chown=node:node --from=build /usr/src/app/client/vcs ./client/vcs

# Expose application port, needed for kubernetes and container orchestration
EXPOSE 3000

# Start the application in production mode
CMD ["npm", "run", "start:prod"]

