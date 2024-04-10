defmodule FotohaeckerWeb.IndexLive.Home.PhotoComponent do
  @moduledoc """
  Single photo thumbnail on the home page.
  """
  use FotohaeckerWeb, :live_component

  def render(assigns) do
    ~H"""
    <%= with id        <- @photo.id,
               title     <- @photo.title,
               file_name <- @photo.file_name,
               extension <- @photo.extension,
               # TODO DRY: don't hardcode paths here…
               thumbs    <- Enum.map([1, 2, 3],
                                     &(Routes.static_path(FotohaeckerWeb.Endpoint,
                                      "/uploads/#{file_name}_thumb@#{&1}x#{extension}"))
                                    ),
               srcset    <- thumbs
                            |> Enum.with_index(&("#{&1} #{&2 + 1}x"))
                            |> Enum.join(", ") do %>
      <li
        class="group block shadow-md transform transition-all duration-300 hover:-translate-y-0.5 hover:shadow-lg active:translate-y-0 active:shadow-md"
        id={"photo-#{id}"}
      >
        <a
          href={photo_route(id)}
          id={"photo__navigate-to-photo-#{id}"}
          data-photo-id={id}
          phx-hook="NavigateToPhoto"
          class="group"
        >
          <span class="sr-only">
            <%= gettext("go to photo %{title} on Fotohäcker", %{title: title}) %>
          </span>
          <img
            class="w-full rounded group-focus:rounded-none"
            src={hd(thumbs)}
            srcset={srcset}
            alt={gettext("photo %{title} on Fotohäcker", %{title: title})}
            loading="lazy"
          />
        </a>
      </li>
    <% end %>
    """
  end
end
