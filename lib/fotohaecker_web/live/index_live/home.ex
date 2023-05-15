defmodule FotohaeckerWeb.IndexLive.Home do
  @doc """
  The one and only LiveView for the home page.
  """
  use FotohaeckerWeb, :live_view

  alias Fotohaecker.Content
  alias Fotohaecker.Content.Photo
  alias FotohaeckerWeb.IndexLive.Home.IntroComponent
  alias FotohaeckerWeb.IndexLive.Home.PhotosComponent

  @submission_params_default %{
    title: "",
    tags: [""]
  }

  def mount(_params, _session, socket) do
    photo_changeset = Content.change_photo(%Photo{}, @submission_params_default)

    socket =
      socket
      |> assign(:uploaded_files, [])
      # prepare upload, maybe refactor..
      |> allow_upload(:photo, accept: ~w(.jpg), max_entries: 1, max_file_size: 20_000_000)
      |> assign(:submission_params, @submission_params_default)
      |> assign(:photo_changeset, photo_changeset)
      |> assign(:uploaded_photo, nil)
      # get latest photos, maybe refactor..
      |> assign(:photos, %{
        user_limit: 5,
        user_order: :desc_inserted_at,
        amount: Content.photos_count(),
        photos: Content.list_photos(5)
      })
      |> assign(page_title: gettext("Home"))

    {:ok, socket}
  end

  defp assign_photos(socket, opts) do
    order = Keyword.get(opts, :order, socket.assigns.photos.user_order)
    limit = Keyword.get(opts, :limit, socket.assigns.photos.user_limit)

    amount = Content.photos_count()
    photos = Content.list_photos(limit, 0, order)

    assign(socket, :photos, %{
      user_limit: if(limit > amount, do: amount, else: limit),
      user_order: order,
      amount: amount,
      photos: photos
    })
  end

  def render(assigns) do
    ~H"""
    <div id="home">
      <div class="bg-experiment"></div>
      <IntroComponent.render
        photo_changeset={@photo_changeset}
        submission_params={@submission_params}
        uploaded_photo={@uploaded_photo}
        uploads={@uploads}
      />
      <PhotosComponent.render photos={@photos} />
    </div>
    """
  end

  def handle_event("sort_by", %{"order" => order}, socket) do
    {:noreply, assign_photos(socket, order: String.to_existing_atom(order))}
  end

  def handle_event("show_more_photos", _params, socket) do
    current_limit = socket.assigns.photos.user_limit
    {:noreply, assign_photos(socket, limit: current_limit + 10)}
  end

  def handle_event("navigate_to", %{"photo_id" => id}, socket) do
    {:noreply, push_navigate(socket, to: photo_route(id))}
  end

  def handle_event("submission_change", %{"photo" => submission_params}, socket) do
    # assign text input values
    # TODO this should be moved to the Photo context to avoid duplication
    submission_params =
      submission_params
      |> Jason.encode!()
      |> Jason.decode!(keys: :atoms!)
      # maybe put file name if file provided
      |> maybe_put_file_name(socket.assigns.uploads.photo.entries)
      |> Map.update!(:tags, &Content.to_tags/1)

    photo_changeset = Content.change_photo(%Photo{}, submission_params)

    socket =
      socket
      |> assign(:submission_params, submission_params)
      |> assign(:photo_changeset, photo_changeset)

    {:noreply, socket}
  end

  def handle_event("submission_generate_tags", %{"value" => photo_id}, socket) do
    photo = Content.get_photo(photo_id)

    # construct file path
    path = Photo.gen_path(photo.file_name) <> "_preview" <> photo.extension

    case Fotohaecker.TagDetection.tags(path) do
      {:ok, tags} ->
        submission_params = Map.put(socket.assigns.submission_params, :tags, tags)
        {:noreply, assign(socket, :submission_params, submission_params)}

      {:error, message} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           gettext("Something went wrong generating tags: %{error}", error: message)
         )}
    end
  end

  def handle_event("submission_submit_tags", %{"photo" => %{"tags" => tags}} = _params, socket) do
    tags = Content.to_tags(tags)

    case Content.update_photo(socket.assigns.uploaded_photo, %{
           tags: tags
         }) do
      {:ok, photo} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Tags updated successfully."))
         |> push_navigate(to: photo_route(photo.id))}

      {:error, changeset} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           gettext("Something went wrong updating your photo: %{error}", error: inspect(changeset))
         )}
    end
  end

  def handle_event("submission_submit", %{"photo" => submission_params}, socket) do
    # assign text input values
    # TODO this should be moved to the Photo context to avoid duplication
    submission_params =
      submission_params
      |> Jason.encode!()
      |> Jason.decode!(keys: :atoms!)
      |> Map.update!(:tags, &Content.to_tags/1)

    upload_result =
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
        dest_name = Photo.gen_path(file_name)
        dest = "#{dest_name}#{extension}"

        # write photo
        File.cp!(path, dest)

        # write thumb
        task_compress =
          Task.async(fn ->
            NodeJS.call("compress", [Photo.gen_path(file_name), extension])
          end)

        # delete original photo afterwards because it's not needed anymore
        Task.await(task_compress, 10_000)
        File.rm!(dest)

        # insert into db
        submission_params
        |> Map.put(:file_name, file_name)
        |> Map.put(:extension, extension)
        |> Content.create_photo()
      end)

    case upload_result do
      [%Photo{} = photo] ->
        {
          :noreply,
          socket
          |> put_flash(:info, gettext("Photo uploaded successfully."))
          |> assign(:submission_params, submission_params)
          |> assign(:uploaded_photo, photo)
        }

      _unknown_upload_result ->
        {
          :noreply,
          put_flash(
            socket,
            :error,
            gettext("Something went wrong uploading your photo. Please try again.")
          )
        }
    end
  end

  # TODO this should be moved to the Photo context to avoid duplication
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
