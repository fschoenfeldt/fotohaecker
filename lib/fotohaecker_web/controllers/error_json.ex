defmodule FotohaeckerWeb.ErrorJSON do
  @behaviour FotohaeckerWeb.SchemaBehaviour

  def schema do
    use PhoenixSwagger

    swagger_schema do
      title("Error")
      description("Error")

      properties do
        errors(array(:object))
      end
    end
  end

  def not_found(_conn) do
    %{
      errors: [
        %{
          status: "404",
          title: "Not found"
        }
      ]
    }
  end
end
