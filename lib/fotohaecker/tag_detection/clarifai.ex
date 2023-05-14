defmodule Fotohaecker.TagDetection.Clarifai do
  @moduledoc """
  Detects tags in a given image using the Clarifai API.
  """

  @behaviour Fotohaecker.TagDetection.TagDetectionBehaviour
  alias Fotohaecker.TagDetection.TagDetectionBehaviour
  @api_secret System.get_env("CLARIFAI_API_SECRET")

  @impl TagDetectionBehaviour
  def caption(image_path),
    do: run("general-english-image-caption-clip", image_path, &get_caption/1)

  @impl TagDetectionBehaviour
  def tags(image_path), do: run("general-image-recognition", image_path, &get_tags/1)

  defp run(modal_id, image_path, extract_fn) do
    image =
      image_path
      |> File.read!()
      |> Base.encode64()

    request = create_request(model_id: modal_id, image: image)

    case HTTPoison.request(request) do
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:ok,
         body
         |> Jason.decode!()
         |> extract_fn.()}
    end
  end

  @spec create_request(model_id: String.t(), image: binary()) :: HTTPoison.Request.t()
  defp create_request(model_id: model_id, image: image) do
    %HTTPoison.Request{
      method: :post,
      url: "https://api.clarifai.com/v2/models/#{model_id}/outputs",
      headers: [
        {"Accept", "application/json"},
        {"Authorization", "Key #{@api_secret}"}
      ],
      body:
        Jason.encode!(%{
          inputs: [
            %{
              data: %{
                image: %{
                  base64: image
                }
              }
            }
          ]
        })
    }
  end

  @spec get_caption(any()) :: String.t()
  defp get_caption(%{"outputs" => outputs}),
    do:
      outputs
      |> hd()
      |> Map.get("data")
      |> Map.get("text")
      |> Map.get("raw")

  defp get_caption(_unknown_api_response), do: nil

  @spec get_tags(any()) :: [String.t()]
  defp get_tags(%{"outputs" => outputs}),
    do:
      outputs
      |> hd()
      |> Map.get("data", %{})
      |> Map.get("concepts", %{})
      |> Enum.map(fn concept -> concept["name"] end)

  defp get_tags(_unknown_api_response), do: []
end
