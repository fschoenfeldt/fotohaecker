defmodule Fotohaecker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Fotohaecker.Repo,
      # Start the Telemetry supervisor
      FotohaeckerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Fotohaecker.PubSub},
      # Start the Endpoint (http/https)
      FotohaeckerWeb.Endpoint,
      # Start a worker by calling: Fotohaecker.Worker.start_link(arg)
      # {Fotohaecker.Worker, arg}
      :hackney_pool.child_spec(:image_detection, timeout: 20_000, max_connections: 10),
      %{
        id: NodeJS,
        start: {NodeJS, :start_link, [[path: "assets/", pool_size: 4]]}
      },
      %{
        id: Fotohaecker.UserManagement,
        start: {Fotohaecker.UserManagement, :start_link, []}
      },
      %{
        id: Fotohaecker.RecipeManagement,
        start: {Fotohaecker.RecipeManagement, :start_link, []}
      }
    ]

    # Parse the swagger schema on startup as described here:
    # - https://hexdocs.pm/phoenix_swagger/PhoenixSwagger.Validator.html#parse_swagger_schema/1
    # - https://github.com/xerions/phoenix_swagger/issues/62#issuecomment-381932391
    # credo:disable-for-next-line
    Task.start_link(fn ->
      [
        :code.priv_dir(:fotohaecker),
        "static",
        "schema.json"
      ]
      |> Path.join()
      |> PhoenixSwagger.Validator.parse_swagger_schema()
    end)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fotohaecker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl Application
  def config_change(changed, _new, removed) do
    FotohaeckerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
