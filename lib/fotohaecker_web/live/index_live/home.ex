defmodule FotohaeckerWeb.IndexLive.Home do
  use FotohaeckerWeb, :live_view

  alias Fotohaecker.Content.Photo


  def mount(_params, _session, socket) do
    upload_params = %{
      title: ""
    }
    upload_changeset = Photo.changeset(%Fotohaecker.Content.Photo{}, upload_params)
    socket = socket |> assign(:upload_params, upload_params) |> assign(:upload_changeset, upload_changeset)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%= inspect assigns %>
    <p>Hello, wörld!</p>

    <.form for={@upload_changeset} multipart={true} phx-submit="upload_submit" phx-change="upload_change">
      <input type="text" name="upload[title]" value={@upload_params.title} placeholder="My fancy title">
      <input type="submit" name="Save">
    </.form>
    """
  end

  def handle_event("upload_change", %{"upload" => upload_params}, socket) do
    upload_params = upload_params |> Jason.encode!() |> Jason.decode!(keys: :atoms!)
    upload_changeset = Photo.changeset(%Fotohaecker.Content.Photo{}, upload_params)

    socket = socket |> assign(:upload_params, upload_params) |> assign(:upload_changeset, upload_changeset)
    {:noreply, socket}
  end

  def handle_event("upload_submit", params, socket) do
    params |> IO.inspect

    {:noreply, socket}
  end
end
