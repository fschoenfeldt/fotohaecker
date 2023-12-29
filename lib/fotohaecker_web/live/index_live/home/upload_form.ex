defmodule FotohaeckerWeb.IndexLive.Home.UploadForm do
  @moduledoc """
  Upload form for photos.
  """
  use FotohaeckerWeb, :live_component

  alias Fotohaecker.Content
  alias Fotohaecker.Content.Photo

  attr :photo_changeset, Ecto.Changeset, required: true
  attr :submission_params, :map, required: true
  attr :uploaded_photo, :any, required: true
  attr :uploads, :map, required: true

  def render(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@photo_changeset}
      multipart={true}
      phx-submit={submit_action(@uploaded_photo)}
      phx-change="submission_change"
      class={[
        "upload_form",
        (length(@uploads.photo.entries) > 0 || @uploaded_photo) && "upload_form--fileselected",
        @uploaded_photo && "upload_form--uploaded"
      ]}
    >
      <%= if @uploaded_photo do %>
        <p>
          <%= @uploaded_photo.title %>
        </p>
        <%= with file_name <- @uploaded_photo.file_name,
                 extension <- @uploaded_photo.extension,
               # TODO DRY: don't hardcode paths here…
                  thumbs     <- Enum.map([1, 2, 3],
                                        &(Routes.static_path(FotohaeckerWeb.Endpoint,
                                        "/uploads/#{file_name}_thumb@#{&1}x#{extension}"))
                                      ),
                  srcset     <- thumbs
                                |> Enum.with_index(&("#{&1} #{&2 + 1}x"))
                                |> Enum.join(", ") do %>
          <img
            class="w-full max-h-[30vh] object-contain"
            src={hd(thumbs)}
            srcset={srcset}
            alt={gettext("photo %{title} on Fotohäcker", %{title: @uploaded_photo.title})}
          />
          <.tags_input f={f} submission_params={@submission_params} photo_id={@uploaded_photo.id} />
        <% end %>
        <div class="flex flex-col gap-2">
          <button class="btn btn--green" type="submit" phx-disable-with={gettext("saving..")}>
            <%= gettext("submit and go to photo") %>
          </button>
          <.link class="block text-sm" href={photo_route(@uploaded_photo.id)}>
            <%= gettext("skip and go to photo") %>
          </.link>
        </div>
      <% else %>
        <div class="md:flex gap-4 w-full">
          <%= for entry <- @uploads.photo.entries do %>
            <.live_img_preview
              entry={entry}
              class="max-w-[50%] max-h-[30vh] hidden md:block object-cover"
            />
            <%!--<figure class="w-full">
                <figcaption><%= entry.client_name %></figcaption>
              </figure>--%>
          <% end %>
          <div class="w-full space-y-4">
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

              <label>
                <.live_file_input upload={@uploads.photo} required />
                <span class="sr-only">
                  <%= gettext("photo upload field") %>
                </span>
              </label>

              <ul class="max-w-sm list-inside list-disc">
                <li class="text-sm text-gray-700 dark:text-gray-200">
                  <%= gettext("accepted file types: .jpg, .jpeg.") %>
                </li>
                <li class="text-sm text-gray-700 dark:text-gray-200">
                  <%= gettext("metadata and exif data will be removed upon upload to ensure privacy.") %>
                </li>
              </ul>

              <%= for entry <- @uploads.photo.entries do %>
                <%= unless Enum.empty?(upload_errors(@uploads.photo, entry)) do %>
                  <div hidden>
                    <%= inspect(entry) %>
                  </div>
                  <div class="">
                    <div class="text-red-500">
                      <%= gettext("the selected file can't be uploaded:") %>
                    </div>

                    <ul class="list-disc list-inside">
                      <%= for err <- upload_errors(@uploads.photo, entry) do %>
                        <li class="text-red-500"><%= error_to_string(err) %></li>
                      <% end %>
                    </ul>
                  </div>
                <% end %>
              <% end %>
            </div>
            <%= for entry <- @uploads.photo.entries do %>
              <div>
                <div aria-hidden="true">
                  <%= gettext("upload progress:") %> <%= if entry.progress == 0,
                    do: gettext("waiting for submission"),
                    else: "#{entry.progress}%" %>
                </div>
                <progress
                  role="progressbar"
                  aria-valuemin="0"
                  aria-valuenow={entry.progress}
                  aria-valuemax="100"
                  value={entry.progress}
                  max="100"
                  aria-label={gettext("upload progress")}
                  class="w-full"
                >
                  <%= entry.progress %>%
                </progress>
              </div>
            <% end %>
            <input
              type="hidden"
              name="photo[tags]"
              value={Content.from_tags(@submission_params.tags)}
            />
            <button class="btn btn--green" type="submit" phx-disable-with={gettext("uploading..")}>
              <%= gettext("upload") %>
            </button>
          </div>
        </div>
      <% end %>
    </.form>
    """
  end

  defp tags_input(assigns) do
    ~H"""
    <div id="photo_tags__wrapper space-y-2">
      <label for="photo_tags">
        <%= gettext("set tags for your uploaded photo") %>
      </label>
      <div class="sm:flex gap-4">
        <input
          id="photo_tags"
          type="text"
          name="photo[tags]"
          placeholder={gettext("photo tags")}
          value={Content.from_tags(@submission_params.tags)}
          phx-debounce="150"
        />
        <button
          phx-click="submission_generate_tags"
          value={@photo_id}
          type="button"
          class="btn btn--blue-outline flex gap-2 items-center text-sm flex-shrink-0 group w-full sm:w-auto justify-center sm:justify-start"
          disabled={length(@submission_params.tags) > 1}
        >
          <Heroicons.cpu_chip class="w-4 h-4 stroke-blue-600 group-hover:stroke-white" />
          <div class="text-blue-600 group-hover:text-white"><%= gettext("generate using AI") %></div>
        </button>
      </div>
      <%= error_tag(@f, :tags) %>
    </div>
    """
  end

  defp submit_action(%Photo{} = _uploaded_photo), do: "submission_submit_tags"
  defp submit_action(_uploaded_photo), do: "submission_submit"

  defp error_to_string(reason), do: Atom.to_string(reason)
end
