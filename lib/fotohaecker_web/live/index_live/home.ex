defmodule FotohaeckerWeb.IndexLive.Home do
  use FotohaeckerWeb, :live_view

  alias Fotohaecker.Content
  alias Fotohaecker.Content.Photo

  def mount(_params, _session, socket) do
    submission_params = %{
      title: ""
    }

    photo_changeset = Content.change_photo(%Photo{}, submission_params)

    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:photo, accept: ~w(.jpg), max_entries: 1)
      |> assign(:submission_params, submission_params)
      |> assign(:photo_changeset, photo_changeset)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="home">
      <div class="bg"></div>
      <div class="intro">
        <h1 class="">
          <%= gettext("Upload your photos, license-free.") %>
        </h1>
        <.form
          :let={f}
          for={@photo_changeset}
          multipart={true}
          phx-submit="submission_submit"
          phx-change="submission_change"
          class="upload_form"
        >
          <div>
            <label for="photo_title">
              Title
            </label>
            <input
              id="photo_title"
              type="text"
              name="photo[title]"
              value={@submission_params.title}
              placeholder="My fancy title"
              required
            />
            <%= error_tag(f, :title) %>
          </div>
          <div phx-drop-target={@uploads.photo.ref} class="dropzone">
            <div>drag the photo here or use the file button below</div>
            <.live_file_input upload={@uploads.photo} />
            <%= for entry <- @uploads.photo.entries do %>
              <div class="">
                <div hidden>
                  <%= inspect(entry) %>
                </div>

                <%= unless Enum.empty?(upload_errors(@uploads.photo, entry)) do %>
                  <div class="">
                    <div class="text-red-500">your upload isn't valid:</div>

                    <ul class="list-disc list-inside">
                      <%= for err <- upload_errors(@uploads.photo, entry) do %>
                        <li class="text-red-500"><%= error_to_string(err) %></li>
                      <% end %>
                    </ul>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
          <button type="submit">
            Upload
          </button>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event("submission_change", %{"photo" => submission_params} = params, socket) do
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

    # |> IO.inspect(label: "after submission_change")

    {:noreply, socket}
  end

  def handle_event("submission_submit", %{"photo" => submission_params}, socket) do
    submission_params |> IO.inspect()

    # assign text input values
    submission_params =
      submission_params
      |> Jason.encode!()
      |> Jason.decode!(keys: :atoms!)
      # maybe put file name if file provided
      |> maybe_put_file_name(socket.assigns.uploads.photo.entries)

    uploaded_files =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, _entry ->
        path |> IO.inspect()

        dest =
          Path.join([
            :code.priv_dir(:fotohaecker),
            "static",
            "images",
            "uploads",
            Path.basename(path)
          ])

        # The `static/uploads` directory must exist for `File.cp!/2` to work.
        File.cp!(path, dest)
        {:ok, Routes.static_path(socket, "/images/uploads/#{Path.basename(dest)}")}
      end)

    # TODO
    # {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}

    # insert into db
    {:ok, %Photo{} = photo} = Content.create_photo(submission_params) |> IO.inspect()

    {:noreply, socket}
  end

  defp error_to_string(reason), do: Atom.to_string(reason)

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
