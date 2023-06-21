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
               thumbs    <- Enum.map([1, 2, 3],
                                     &(Routes.static_path(FotohaeckerWeb.Endpoint,
                                      "/uploads/#{file_name}_thumb@#{&1}x#{extension}"))
                                    ),
               srcset    <- thumbs
                            |> Enum.with_index(&("#{&1} #{&2 + 1}x"))
                            |> Enum.join(", ") do %>
      <li class="block" id={"photo-#{id}"}>
        <a
          href={photo_route(id)}
          id={"photo__navigate-to-photo-#{id}"}
          data-photo-id={id}
          phx-hook="NavigateToPhoto"
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
        </a>
      </li>
    <% end %>
    """
  end
end
