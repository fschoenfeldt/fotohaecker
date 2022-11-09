defmodule Fotohaecker.TagDetection.Clarifai do
  @moduledoc """
  Detects tags in a given image using the Clarifai API.
  """

  @behaviour Fotohaecker.TagDetection
  alias Fotohaecker.TagDetection

  @impl TagDetection
  def caption(_image) do
    model_id = "general-english-image-caption-clip"

    # get the credentials from the application config
    %{credentials: %{api_secret: api_secret}} = Application.get_env(:fotohaecker, TagDetection)

    # TODO use actual photo and not fixture
    image = File.read!("priv/static/images/uploads/my-first-photo_thumb@3x.jpg")

    {:ok, %HTTPoison.Response{body: response}} =
      create_request(model_id: model_id, api_secret: api_secret, image: image)
      |> HTTPoison.request()

    {:ok, response |> Jason.decode!() |> get_caption()}
  end

  @impl TagDetection
  def tags(_image) do
    model_id = "general-image-recognition"

    # get the credentials from the application config
    %{credentials: %{api_secret: api_secret}} = Application.get_env(:fotohaecker, TagDetection)

    # TODO use actual photo and not fixture
    image = File.read!("priv/static/images/uploads/my-first-photo_thumb@3x.jpg")

    {:ok, %HTTPoison.Response{body: response}} =
      create_request(model_id: model_id, api_secret: api_secret, image: image)
      |> HTTPoison.request()

    {:ok,
     response
     |> Jason.decode!()
     |> get_tags()}
  end

  @spec create_request(any()) :: HTTPoison.Request.t()
  defp create_request(model_id: model_id, api_secret: api_secret, image: image) do
    %HTTPoison.Request{
      method: :post,
      url: "https://api.clarifai.com/v2/models/#{model_id}/outputs",
      headers: [
        {"Accept", "application/json"},
        {"Authorization", "Key #{api_secret}"}
      ],
      body:
        Jason.encode!(%{
          inputs: [
            %{
              data: %{
                image: %{
                  base64: Base.encode64(image)
                }
              }
            }
          ]
        })
    }
  end

  @spec get_caption(any()) :: String.t()
  defp get_caption(%{"outputs" => outputs}) do
    outputs |> hd() |> Map.get("data") |> Map.get("text") |> Map.get("raw")
  end

  @spec get_tags(any()) :: [String.t()]
  defp get_tags(%{"outputs" => outputs}) do
    outputs
    |> hd()
    |> Map.get("data")
    |> Map.get("concepts")

    # TODO actually return list of tags here
  end
end
