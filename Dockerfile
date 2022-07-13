# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian instead of
# Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20210902-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.13.4-erlang-24.3.4-debian-bullseye-20210902-slim
#
ARG BUILDER_IMAGE="hexpm/elixir:1.13.4-erlang-24.3.4-debian-bullseye-20210902-slim"
ARG RUNNER_IMAGE=debian:11.4-slim

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git npm \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
COPY apps/novy/mix.exs /app/apps/novy/
COPY apps/novy_web/mix.exs /app/apps/novy_web/
COPY apps/novy_admin/mix.exs /app/apps/novy_admin/
COPY apps/novy_api/mix.exs /app/apps/novy_api/

RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY apps/novy/lib /app/apps/novy/lib/
COPY apps/novy_web/lib /app/apps/novy_web/lib/
COPY apps/novy_admin/lib /app/apps/novy_admin/lib/
COPY apps/novy_api/lib /app/apps/novy_api/lib/

COPY apps/novy/priv /app/apps/novy/priv
COPY apps/novy_web/priv /app/apps/novy_web/priv
COPY apps/novy_admin/priv /app/apps/novy_admin/priv
# COPY apps/novy_api/priv /app/apps/novy_api/priv

# note: if your project uses a tool like https://purgecss.com/,
# which customizes asset compilation based on what it finds in
# your Elixir templates, you will need to move the asset compilation
# step down so that `lib` is available.
COPY apps/novy_web/assets /app/apps/novy_web/assets
COPY apps/novy_admin/assets /app/apps/novy_admin/assets

# compile assets
WORKDIR /app/apps/novy_web
RUN npm --prefix ./assets ci --frozen-lockfile
RUN npm run --prefix ./assets deploy
RUN mix assets.deploy

WORKDIR /app/apps/novy_admin
RUN npm --prefix ./assets ci --frozen-lockfile
RUN npm run --prefix ./assets deploy
RUN mix assets.deploy

WORKDIR /app

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/fr_FR.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV LC_ALL fr_FR.UTF-8

WORKDIR "/app"

RUN chown nobody /app

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/prod/rel/novy_umbrella ./

USER nobody

CMD ["/app/bin/server"]

# Appended by flyctl
ENV ECTO_IPV6 true
ENV ERL_AFLAGS "-proto_dist inet6_tcp"