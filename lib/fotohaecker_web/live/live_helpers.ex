defmodule FotohaeckerWeb.LiveHelpers do
  @moduledoc false
  import Phoenix.Component
  use Phoenix.Component

  alias FotohaeckerWeb.Router.Helpers
  alias Fotohaecker.Content.Photo
  alias Fotohaecker.Content.Recipe
  alias Phoenix.LiveView.JS

  require FotohaeckerWeb.Gettext

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.photo_index_path(@socket, :index)}>
        <.live_component
          module={FotohaeckerWeb.PhotoLive.FormComponent}
          id={@photo.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.photo_index_path(@socket, :index)}
          photo: @photo
        />
      </.modal>
  """

  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
      <div
        x-data="modal"
        id="modal-content"
        class="phx-modal-content fade-in-scale text-signature-grey"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
        role="dialog"
        aria-modal="true"
        aria-labelledby="modalLabel"
      >
        <div class="flex justify-between">
          <%= if Map.get(assigns, :title) do %>
            <h2 class="text-signature-grey" id="modalLabel" class="phx-modal-title"><%= @title %></h2>
          <% end %>
          <%= if @return_to do %>
            <.link patch={@return_to} phx-click={hide_modal()} id="close" class="phx-modal-close">
              <Heroicons.x_mark class="w-6 h-6" />
              <span class="sr-only"><%= FotohaeckerWeb.Gettext.gettext("close") %></span>
            </.link>
          <% else %>
            <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>
              <Heroicons.x_mark class="w-6 h-6" />
            </a>
          <% end %>
        </div>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end

  @doc """
  Renders a user profile link for a given photo if `Fotohaecker.UserManagement` is implemented, otherwise prints 'anonymous user'.
  """
  attr :photo, Photo
  attr :recipe, Recipe
  # TODO: test
  # TODO: maybe don't extract user_id here but have it passed in as an argument
  def user_profile_link(assigns) do
    ~H"""
    <span class="text-gray-700 dark:text-gray-300 italic">
      <%= with maybe_user_id_from_photo   <- assigns
                                             |> Map.get(:photo, %{})
                                             |> Map.get(:user_id),
               maybe_user_id_from_recipe  <- assigns
                                             |> Map.get(:recipe, %{})
                                             |> Map.get(:user_id),
               user_id                    <- maybe_user_id_from_photo || maybe_user_id_from_recipe do %>
        <%= if user_id === nil do %>
          <%= FotohaeckerWeb.Gettext.gettext("by an anonymous user") %>
        <% else %>
          <%= case Fotohaecker.UserManagement.get(user_id) do %>
            <% {:ok, user} -> %>
              <a href={user_route(user_id)}>
                <%= FotohaeckerWeb.Gettext.gettext("by %{user}", %{user: user.nickname}) %>
              </a>
            <% _ -> %>
              <%= if Fotohaecker.UserManagement.is_implemented?() do %>
                <a href={user_route(user_id)}>
                  <%= FotohaeckerWeb.Gettext.gettext("by user_id %{user_id}", %{
                    user_id: user_id
                  }) %>
                </a>
              <% else %>
                <%= FotohaeckerWeb.Gettext.gettext("by user %{user_id}", %{user_id: user_id}) %>
              <% end %>
          <% end %>
        <% end %>
      <% end %>
    </span>
    """
  end

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

  def photo_url(id),
    do:
      Helpers.photo_show_url(
        FotohaeckerWeb.Endpoint,
        :show,
        Gettext.get_locale(FotohaeckerWeb.Gettext),
        id
      )

  def photo_urls(%Photo{} = photo) do
    %{
      raw: public_photo_src_url(photo, "og"),
      full: public_photo_src_url(photo, "preview"),
      thumb1x: public_photo_src_url(photo, "thumb@1x"),
      thumb2x: public_photo_src_url(photo, "thumb@2x"),
      thumb3x: public_photo_src_url(photo, "thumb@3x")
    }
  end

  defp public_photo_src_url(photo, type) do
    FotohaeckerWeb.Endpoint.url() <>
      Helpers.static_path(
        FotohaeckerWeb.Endpoint,
        "/uploads/#{photo.file_name}_#{type}#{photo.extension}"
      )
  end

  def photo_route(id),
    do:
      Helpers.photo_show_path(
        FotohaeckerWeb.Endpoint,
        :show,
        Gettext.get_locale(FotohaeckerWeb.Gettext),
        id
      )

  def recipe_route(id),
    do:
      Helpers.recipe_show_path(
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
