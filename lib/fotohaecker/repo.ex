defmodule Fotohaecker.Repo do
  use Ecto.Repo,
    otp_app: :fotohaecker,
    adapter: Ecto.Adapters.SQLite3
end
