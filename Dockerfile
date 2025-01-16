FROM node:23-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app

# Only copy necessary files for build (avoid unnecessary files like .git)
COPY package.json pnpm-lock.yaml /app/

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile

# Run the build step and output to a known directory
RUN pnpm deploy --filter=@imput/cobalt-api --prod /app/prod/api

# Add debugging to check output location
RUN ls -R /app/prod/

FROM base AS api
WORKDIR /app

# Update this to the correct output path from the build step
COPY --from=build --chown=node:node /app/prod/api /app

USER node

EXPOSE 9000

CMD [ "node", "src/cobalt" ]
