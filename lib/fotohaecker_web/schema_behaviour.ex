defmodule FotohaeckerWeb.SchemaBehaviour do
  @moduledoc """
  Behaviour for schema modules that are used to generate Swagger schemas.
  """

  @callback schema() :: PhoenixSwagger.Schema
end
