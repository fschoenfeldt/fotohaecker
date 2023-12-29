defmodule FotohaeckerWeb.LiveHelpers do
  @moduledoc false
  # import Phoenix.LiveView.Helpers
  # import Phoenix.Component

  alias FotohaeckerWeb.Router.Helpers
  alias Fotohaecker.Content.Photo
  # alias Phoenix.LiveView.JS

  require FotohaeckerWeb.Gettext

  # @doc """
  # Renders a live component inside a modal.

  # The rendered modal receives a `:return_to` option to properly update
  # the URL when the modal is closed.

  # ## Examples

  #     <.modal return_to={Routes.photo_index_path(@socket, :index)}>
  #       <.live_component
  #         module={FotohaeckerWeb.PhotoLive.FormComponent}
  #         id={@photo.id || :new}
  #         title={@page_title}
  #         action={@live_action}
  #         return_to={Routes.photo_index_path(@socket, :index)}
  #         photo: @photo
  #       />
  #     </.modal>
  # """

  # def modal(assigns) do
  #   assigns = assign_new(assigns, :return_to, fn -> nil end)

  #   ~H"""
  #   <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
  #     <div
  #       id="modal-content"
  #       class="phx-modal-content fade-in-scale"
  #       phx-click-away={JS.dispatch("click", to: "#close")}
  #       phx-window-keydown={JS.dispatch("click", to: "#close")}
  #       phx-key="escape"
  #     >
  #       <%= if @return_to do %>
  #         <%= live_patch("✖",
  #           to: @return_to,
  #           id: "close",
  #           class: "phx-modal-close",
  #           phx_click: hide_modal()
  #         ) %>
  #       <% else %>
  #         <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>✖</a>
  #       <% end %>

  #       <%= render_slot(@inner_block) %>
  #     </div>
  #   </div>
  #   """
  # end

  # defp hide_modal(js \\ %JS{}) do
  #   js
  #   |> JS.hide(to: "#modal", transition: "fade-out")
  #   |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  # end

  def locale_gui("de_DE" = locale),
    do: {
      FotohaeckerWeb.Gettext.gettext("german"),
      static("/images/flags/#{locale}.svg")
    }

  def locale_gui("en_US" = locale),
    do: {
      FotohaeckerWeb.Gettext.gettext("english"),
      static("/images/flags/#{locale}.svg")
    }

  def home_route(params \\ %{}),
    do:
      Helpers.index_home_path(
        FotohaeckerWeb.Endpoint,
        :home,
        Gettext.get_locale(FotohaeckerWeb.Gettext),
        params
      )

  def photo_link(id), do: photo_url(id)

  # TODO: this function name is maybe confusing with other *_url functions
  defp photo_url(id),
    do:
      Helpers.photo_show_url(
        FotohaeckerWeb.Endpoint,
        :show,
        Gettext.get_locale(FotohaeckerWeb.Gettext),
        id
      )

  def photo_urls(%Photo{} = photo) do
    %{
      raw:
        Helpers.static_url(
          FotohaeckerWeb.Endpoint,
          "/uploads/#{photo.file_name}_og#{photo.extension}"
        ),
      full:
        Helpers.static_url(
          FotohaeckerWeb.Endpoint,
          "/uploads/#{photo.file_name}_preview#{photo.extension}"
        ),
      thumb1x:
        Helpers.static_url(
          FotohaeckerWeb.Endpoint,
          "/uploads/#{photo.file_name}_thumb@1x#{photo.extension}"
        ),
      thumb2x:
        Helpers.static_url(
          FotohaeckerWeb.Endpoint,
          "/uploads/#{photo.file_name}_thumb@2x#{photo.extension}"
        ),
      thumb3x:
        Helpers.static_url(
          FotohaeckerWeb.Endpoint,
          "/uploads/#{photo.file_name}_thumb@3x#{photo.extension}"
        )
    }
  end

  def photo_route(id),
    do:
      Helpers.photo_show_path(
        FotohaeckerWeb.Endpoint,
        :show,
        Gettext.get_locale(FotohaeckerWeb.Gettext),
        id
      )

  def user_route(id),
    do:
      Helpers.user_show_path(
        FotohaeckerWeb.Endpoint,
        :show,
        Gettext.get_locale(FotohaeckerWeb.Gettext),
        id
      )

  def user_url(id),
    do:
      Helpers.user_show_url(
        FotohaeckerWeb.Endpoint,
        :show,
        Gettext.get_locale(FotohaeckerWeb.Gettext),
        id
      )

  def static(path), do: Helpers.static_path(FotohaeckerWeb.Endpoint, path)
end
