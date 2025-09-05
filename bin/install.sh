#!/bin/bash
set -x

# setup project on remote server

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

## build assets
mix phx.digest.clean
npm --prefix assets install
mix assets.deploy

