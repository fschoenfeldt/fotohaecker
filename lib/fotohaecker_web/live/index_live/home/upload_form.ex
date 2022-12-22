defmodule FotohaeckerWeb.IndexLive.Home.UploadForm do
  @moduledoc """
  Upload form for photos.
  """
  use FotohaeckerWeb, :live_component

  def render(assigns) do
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
        <.live_file_input upload={@uploads.photo} required />
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

  defp error_to_string(reason), do: Atom.to_string(reason)
end
