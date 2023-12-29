defmodule FotohaeckerWeb.ErrorJSON do
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
