FROM node:23-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app

# Only copy necessary files for build
COPY package.json pnpm-lock.yaml /app/

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile

# Run the deploy command without specifying the output directory
RUN pnpm deploy --filter=@imput/cobalt-api --prod

# Debugging to check where files are output
RUN ls -R /app

FROM base AS api
WORKDIR /app

# Update the copy step according to the correct path
COPY --from=build --chown=node:node /app /app

USER node

EXPOSE 9000

CMD [ "node", "FastSaveFromNetBackend/api/src/cobalt" ]
