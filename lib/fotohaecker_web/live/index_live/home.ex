defmodule FotohaeckerWeb.IndexLive.Home do
  use FotohaeckerWeb, :live_view

  alias Fotohaecker.Content
  alias Fotohaecker.Content.Photo
  alias FotohaeckerWeb.IndexLive.Home.{PhotosComponent, UploadForm}

  def mount(_params, _session, socket) do
    submission_params = %{
      title: ""
    }

    photo_changeset = Content.change_photo(%Photo{}, submission_params)

    socket =
      socket
      |> assign(:uploaded_files, [])
      # prepare upload, maybe refactor..
      |> allow_upload(:photo, accept: ~w(.jpg), max_entries: 1, max_file_size: 20_000_000)
      |> assign(:submission_params, submission_params)
      |> assign(:photo_changeset, photo_changeset)
      # get latest photos, maybe refactor..
      |> assign(:photos, Enum.reverse(Content.list_photos()))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="home">
      <div class="bg-experiment"></div>
      <.intro
        photo_changeset={@photo_changeset}
        submission_params={@submission_params}
        uploads={@uploads}
      />
      <PhotosComponent.render photos={@photos} />
    </div>
    """
  end

  defp intro(assigns) do
    ~H"""
    <div class="intro">
      <h1 class="">
        <%= gettext("Upload your photos, license-free.") %>
      </h1>
      <UploadForm.render
        photo_changeset={@photo_changeset}
        submission_params={@submission_params}
        uploads={@uploads}
      />
    </div>
    """
  end

  def handle_event("navigate_to", %{"photo_id" => id}, socket) do
    {:noreply, push_navigate(socket, to: photo_route(id))}
  end

  def handle_event("submission_change", %{"photo" => submission_params}, socket) do
    # assign text input values
    submission_params =
      submission_params
      |> Jason.encode!()
      |> Jason.decode!(keys: :atoms!)
      # maybe put file name if file provided
      |> maybe_put_file_name(socket.assigns.uploads.photo.entries)

    photo_changeset = Content.change_photo(%Photo{}, submission_params)

    socket =
      socket
      |> assign(:submission_params, submission_params)
      |> assign(:photo_changeset, photo_changeset)

    {:noreply, socket}
  end

  def handle_event("submission_submit", %{"photo" => submission_params}, socket) do
    # assign text input values
    submission_params =
      submission_params
      |> Jason.encode!()
      |> Jason.decode!(keys: :atoms!)

    _uploaded_files =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, entry ->
        extension =
          case entry.client_type do
            "image/jpeg" ->
              ".jpg"

            # "image/png" ->
            #   ".png"

            _type ->
              raise "Unsupported Type. This error shouldn't happen as it's configured via LiveView Upload."
          end

        file_name = Path.basename(path)
        dest = "#{Photo.gen_path(file_name)}#{extension}"

        # write photo
        File.cp!(path, dest)

        # write thumb
        Task.async(fn ->
          NodeJS.call("compress", [Photo.gen_path(file_name), extension])
        end)

        # insert into db
        {:ok, %Photo{}} =
          submission_params
          |> Map.put(:file_name, file_name)
          |> Map.put(:extension, extension)
          |> Content.create_photo()

        {:ok, Routes.static_path(socket, "/images/uploads/#{file_name}#{extension}")}
      end)

    # file could be appended with phx-update
    # {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}

    # TODO the update of the page can be done much more gracefully by appending
    {:noreply, push_redirect(socket, to: home_route())}
  end

  defp maybe_put_file_name(params, entries) do
    if Enum.empty?(entries) do
      params
    else
      %Phoenix.LiveView.UploadEntry{
        uuid: filename
      } = hd(entries)

      Map.put_new(params, :file_name, ~s(#{filename}.jpg))
    end
  end
end
