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
      # prepare upload, maybe refactor..
      |> allow_upload(:photo, accept: ~w(.jpg), max_entries: 1, max_file_size: 20_000_000)
      |> assign(:submission_params, submission_params)
      |> assign(:photo_changeset, photo_changeset)
      # get latest photos, maybe refactor..
      |> assign(:photos, Content.list_photos())

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
      <.photos photos={@photos} />
    </div>
    """
  end

  defp intro(assigns) do
    ~H"""
    <div class="intro">
      <h1 class="">
        <%= gettext("Upload your photos, license-free.") %>
      </h1>
      <.upload_form
        photo_changeset={@photo_changeset}
        submission_params={@submission_params}
        uploads={@uploads}
      />
    </div>
    """
  end

  defp upload_form(assigns) do
    ~H"""
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
          <%= gettext("title") %>
        </label>
        <input
          id="photo_title"
          type="text"
          name="photo[title]"
          placeholder={gettext("photo title")}
          required
          value={@submission_params.title}
          phx-debounce="150"
        />
        <%= error_tag(f, :title) %>
      </div>
      <div phx-drop-target={@uploads.photo.ref} class="dropzone">
        <div class="dark:text-gray-200" aria-hidden="true">
          <%= gettext("drag the photo here or use the file button below") %>
        </div>
        <.live_file_input upload={@uploads.photo} />
        <%= for entry <- @uploads.photo.entries do %>
          <%= unless Enum.empty?(upload_errors(@uploads.photo, entry)) do %>
            <div hidden>
              <%= inspect(entry) %>
            </div>
            <div class="">
              <div class="text-red-500"><%= gettext("the selected file can't be uploaded:") %></div>

              <ul class="list-disc list-inside">
                <%= for err <- upload_errors(@uploads.photo, entry) do %>
                  <li class="text-red-500"><%= error_to_string(err) %></li>
                <% end %>
              </ul>
            </div>
          <% end %>
        <% end %>
      </div>
      <button class="btn btn--green" type="submit" phx-disable-with={gettext("uploading..")}>
        <%= gettext("upload") %>
      </button>
    </.form>
    """
  end

  defp photos(assigns) do
    ~H"""
    <div class="photos">
      <%!-- #TODO do this via form, with single select that can be more accessible --%>
      <p class="sr-only"><%= gettext("sort by") %></p>
      <ul class="sortby-options">
        <li>
          <a href="#" class="sortby-options__option sortby-options__option--active">
            <%= gettext("latest") %> <span class="sr-only"><%= gettext("(active)") %></span>
          </a>
        </li>
        <li>
          <a href="#" class="sortby-options__option">
            <%= gettext("oldest") %>
          </a>
        </li>
        <li>
          <a href="#" class="sortby-options__option">
            <%= gettext("most downloaded") %>
          </a>
        </li>
      </ul>

      <%= if Enum.empty?(@photos) do %>
        <div class="text-center">
          <p class="text-gray-500 dark:text-gray-400 italic">
            <%= gettext("no photos, yet...") %>
          </p>
        </div>
      <% else %>
        <div class="columns-2 md:columns-3 lg:columns-4 space-y-4 gap-4">
          <%= for photo <- @photos do %>
            <.photo photo={photo} />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp photo(assigns) do
    ~H"""
    <div class="">
      <%= with id        <- @photo.id,
               title     <- @photo.title,
               file_name <- @photo.file_name,
               extension <- @photo.extension,
               thumbs    <- Enum.map([1, 2, 3],
                                     &(Routes.static_path(FotohaeckerWeb.Endpoint,
                                      "/images/uploads/#{file_name}_thumb@#{&1}x#{extension}"))
                                    ),
               srcset    <- thumbs
                            |> Enum.with_index(&("#{&1} #{&2 + 1}x"))
                            |> Enum.join(", ") do %>
        <%!-- #TODO href should be set --%>
        <div
          class="block"
          phx-click="navigate_to"
          phx-keydown="navigate_to"
          phx-key="Enter"
          phx-value-photo_id={id}
          tabindex="0"
          aria-describedby={"photo-#{id}-title"}
        >
          <span class="sr-only">
            <%= gettext("go to photo %{title} on Fotohäcker", %{title: title}) %>
          </span>
          <img
            class="w-full"
            src={hd(thumbs)}
            srcset={srcset}
            alt={gettext("photo %{title} on Fotohäcker", %{title: title})}
            loading="lazy"
          />
        </div>
      <% end %>
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
          NodeJS.call("compress", [Photo.gen_path(file_name), extension]) |> IO.inspect()
        end)
        |> IO.inspect()

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
