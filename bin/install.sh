#!/bin/bash
set -x

# setup project on remote server
#
# NOTE: server quirks (uberspace, as of 2026-10):
#   - glibc 2.17: prebuilt binaries needing a newer glibc don't run
#     (e.g. pnpm's standalone binary)
#   - Erlang/OTP 28 (ssl 11.3.2) fails the TLS handshake with GitHub's
#     release CDN, so mix tasks can't download release assets from GitHub.
#     hex.pm and the npm registry work fine.

## set environment variables
export MIX_ENV="prod"

### we need to use uberspace's exqlite installation
### because we cannot compile exqlite on the server
export EXQLITE_USE_SYSTEM=1
export EXQLITE_SYSTEM_CFLAGS="-I/usr/include"
export EXQLITE_SYSTEM_LDFLAGS="-L/lib64/sqlite -lsqlite3"

## get dependencies and compile
mix deps.get --only prod
mix compile

## setup assets
### Erlang/OTP 28's ssl fails the TLS handshake with GitHub's release CDN,
### so download the tailwind binary with curl instead of `mix tailwind.install`
TAILWIND_VERSION=$(sed -n '/config :tailwind/,/version:/s/.*version: "\(.*\)".*/\1/p' config/config.exs)
curl -fsSL -o "_build/tailwind-linux-x64-$TAILWIND_VERSION" \
  "https://github.com/tailwindlabs/tailwindcss/releases/download/v$TAILWIND_VERSION/tailwindcss-linux-x64"
chmod +x "_build/tailwind-linux-x64-$TAILWIND_VERSION"
mix esbuild.install

## build assets
mix phx.digest.clean
### requires pnpm 10, installed via `npm install -g pnpm@10`.
### don't use `pnpm self-update` or the standalone installer: their
### binaries need a newer glibc than the server has
pnpm --dir assets install --frozen-lockfile
mix assets.deploy

