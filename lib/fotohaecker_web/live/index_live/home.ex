defmodule FotohaeckerWeb.IndexLive.Home do
  use FotohaeckerWeb, :live_view

  alias Fotohaecker.Content.Photo

  def mount(_params, _session, socket) do
    submission_params = %{
      title: ""
    }

    photo_changeset = Photo.changeset(%Photo{}, submission_params)

    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:avatar, accept: ~w(.jpg .jpeg), max_entries: 2)
      # |> allow_upload(:photo, accept: ~w(.jpg), max_entries: 1)
      |> assign(:submission_params, submission_params)
      |> assign(:photo_changeset, photo_changeset)

    IO.inspect(socket.assigns.uploads.avatar, limit: :infinity)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%= inspect(assigns) %>
    <p>Hello, wörld!</p>

    <.form
      for={@photo_changeset}
      multipart={true}
      phx-submit="submission_submit"
      phx-change="submission_change"
    >
      <input
        type="text"
        name="upload[title]"
        value={@submission_params.title}
        placeholder="My fancy title"
      />
      <.live_file_input upload={@uploads.avatar} />
      <%!-- <.live_file_input upload={@uploads.photo} /> --%>
      <%!-- <div phx-drop-target={@uploads.photo.ref} class="h-10 w-10 bg-gray-200"></div> --%>
      <input type="submit" name="Save" />
    </.form>
    """
  end

  def handle_event("submission_change", %{"upload" => submission_params} = params, socket) do
    params |> IO.inspect()
    submission_params = submission_params |> Jason.encode!() |> Jason.decode!(keys: :atoms!)
    photo_changeset = Photo.changeset(%Fotohaecker.Content.Photo{}, submission_params)

    socket =
      socket
      |> assign(:submission_params, submission_params)
      |> assign(:photo_changeset, photo_changeset)

    {:noreply, socket}
  end

  def handle_event("submission_submit", params, socket) do
    params |> IO.inspect()

    {:noreply, socket}
  end
end
