FROM hexpm/elixir:1.12.2-erlang-24.0.3-alpine-3.14.0 AS build

# install build dependencies
RUN apk add --no-cache build-base npm
RUN npm install -g pnpm

# prepare build dir
WORKDIR /app

# extend hex timeout
ENV HEX_HTTP_TIMEOUT=20

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV as prod
ENV MIX_ENV=prod

# Copy over the mix.exs and mix.lock files to load the dependencies. If those
# files don't change, then we don't keep re-fetching and rebuilding the deps.
COPY mix.exs mix.lock ./
COPY config config

COPY apps/novy_data/mix.exs /app/apps/novy_data/
COPY apps/novy_api/mix.exs /app/apps/novy_api/
COPY apps/novy_site/mix.exs /app/apps/novy_site/
COPY apps/novy_admin/mix.exs /app/apps/novy_admin/

RUN mix deps.get --only prod && \
    mix deps.compile

COPY . .

# build assets
WORKDIR /app/apps/novy_site
RUN pnpm --prefix ./assets install --frozen-lockfile
RUN pnpm run --prefix ./assets deploy
RUN mix phx.digest

WORKDIR /app/apps/novy_admin
RUN pnpm --prefix ./assets install --frozen-lockfile
RUN pnpm run --prefix ./assets deploy
RUN mix phx.digest

WORKDIR /app
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix docs
RUN mix compile
RUN mix release

########################################################################

# prepare release image
# FROM alpine AS app
FROM nginx:stable-alpine AS app
RUN apk add --no-cache openssl ncurses-libs libstdc++

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/novy ./
COPY --from=build --chown=nobody:nobody /app/entrypoint.sh ./
COPY --from=build --chown=nobody:nobody /app/doc ./doc/

ENV HOME=/app

COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]
