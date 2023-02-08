# Fotohaecker

Live Demo: https://fschoenf.uber.space/fh/

## Installation

This project uses [asdf](https://asdf-vm.com/#/) to manage development dependencies.

### Get required asdf plugins

- [Elixir](https://github.com/asdf-vm/asdf-elixir#install)
- [Erlang OTP](https://github.com/asdf-vm/asdf-erlang#install)
- [NodeJS](https://github.com/asdf-vm/asdf-nodejs#install)
- [Direnv](https://github.com/asdf-community/asdf-direnv#setup)

### Install development dependencies

```shell
asdf install
# copy .envrc.local.example to .envrc.local
cp .envrc.local.example .envrc.local
# allow via direnv
direnv allow
```

### Setup & Start Server

To start your Phoenix server:

- Install with `mix setup`
- provide a valid `SECRET_KEY_BASE` in your `.envrc.local`, generate one with `mix phx.gen.secret`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:1337`](http://localhost:1337) from your browser.

---

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Acknowledgements

- Locale flags provided by https://flag.pk/
