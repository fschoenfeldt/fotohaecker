# Fotohaecker

## Installation

```shell
# get required tools
asdf install
# copy .envrc.local.example to .envrc.local
cp .envrc.local.example .envrc.local
# allow via direnv
direnv allow
```

### Prerequisites

Fotohäcker uses [Image](https://hexdocs.pm/image) for image upload compression, which in turn [requires libvips](https://hexdocs.pm/image/readme.html#installing-libvips). Refer to Images' documentation on how to install it.

### Setup & Start Server

To start your Phoenix server:

- Install with `mix setup`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:1337`](http://localhost:1337) from your browser.

---

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Acknowledgements

- Locale flags provided by https://flag.pk/
