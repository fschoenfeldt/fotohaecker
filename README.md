# Fotohaecker

Live Demo: https://fschoenf.uber.space/fh/

## Installation

This project uses [asdf](https://asdf-vm.com/#/) to manage development dependencies.

### Get required asdf plugins

- [Elixir](https://github.com/asdf-vm/asdf-elixir#install)
- [Erlang OTP](https://github.com/asdf-vm/asdf-erlang#install)
- [NodeJS](https://github.com/asdf-vm/asdf-nodejs#install)
- [Direnv](https://github.com/asdf-community/asdf-direnv#setup)
- [pnpm](https://github.com/jonathanmorley/asdf-pnpm#installing)

### Install development dependencies

```shell
asdf install
# copy .envrc.local.example to .envrc.local
cp .envrc.local.example .envrc.local
# allow via direnv
direnv allow
```

## Development

### Setup & Start Server

To start your Phoenix server:

- Install with `mix setup`
- provide a valid `SECRET_KEY_BASE` in your `.envrc.local`, generate one with `mix phx.gen.secret`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:1337/fh`](http://localhost:1337/fh) from your browser.

### Unit Tests / Quality

```shell
mix check
```

### E2E Tests

```shell
# install deps
mix e2e.setup
# run tests
pnpm --prefix test/e2e test
# .. with traces
pnpm --prefix test/e2e test -- --trace on
# .. with traces and headed
pnpm --prefix test/e2e test -- --trace on --headed
```

## Deployment

### Setup `envrc.local`

To deploy your application to uberspace, make sure to set the required variables in your `.envrc.local`.

#### ensure access to uberspace

You should be able to ssh onto this server in order to deploy. Try it out with this:

```shell
# access shell
ssh user@server.uberspace.de
# you should be on the server now.
[user@server]~$ exit
```

### setup uberspace (remote)

#### prepare supervisord config

copy the `_uberspace/fotohaeckertwo.ini.example` to `_uberspace/fotohaeckertwo.ini`

```shell
cp _uberspace/fotohaeckertwo.ini.example _uberspace/fotohaeckertwo.ini
```

now, insert the neccessary environment variables.

#### adding web backend

you need to add the [web backend](https://manual.uberspace.de/web-backends/) to your uberspace server. You can do this with the following commands:

```shell
# set web backend
uberspace web backend set /fh --http --port $TFP_PORT
# verify
[user@server]~% uberspace web backend list
/fh http:6000 => NOT OK, no service
/ apache (default)
```

#### deploy!1

Now you can deploy your application to uberspace. You can do this with the following script:

```shell
./bin/deploy.sh
```

_This executes some rsync and ssh commands, you might get asked for your password multiple times. Also, if you run this the first time, Elixir asks you if you want to install Hex/rebar3, which you interactively agree to._

#### seed database

In case you want to re-run the seed script, you can do this with the following command:

```shell
[user@server]~% DATABASE_PATH=/path/to/db SECRET_KEY_BASE=DOESNT_MATTER MIX_ENV=prod mix ecto.reset
```

#### Troubleshoting

##### check for tool versions

When in doubt, check the versions of the tools you are using. You can do this with the following commands:

###### Elixir/OTP

Make sure to use the Elixir/OTP version closest to the one specified in the `.tool-versions` file. You can check the current version with the following command:

```shell
[user@server]~% uberspace tools version show erlang
```

👉 https://manual.uberspace.de/lang-erlang/

###### Node

Make sure to use the Node version closest to the one specified in the `.tool-versions` file. You can check the current version with the following command:

```shell
[user@server]~% uberspace tools version show node
```

---

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Acknowledgements

- Locale flags provided by https://flag.pk/
