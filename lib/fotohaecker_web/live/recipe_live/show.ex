defmodule FotohaeckerWeb.RecipeLive.Show do
  alias Fotohaecker.Content.Photo
  alias Fotohaecker.Content.Recipe
  alias Fotohaecker.Content
  alias FotohaeckerWeb.IndexLive.Home.PhotoComponent

  use FotohaeckerWeb, :live_view

  def mount(params, _session, socket) do
    # FIXME: error handing 404 when recipe not found
    recipe =
      Content.get_recipe!(params["id"], [
        :photos
      ])

    {:ok, assign(socket, recipe: recipe)}
  end

  def render(assigns) do
    ~H"""
    <%!-- # FIXME: think about tailwind typography --%>
    <div class="space-y-2 p-4">
      <article class="prose">
        <h1><%= gettext("Recipe") %>: <%= @recipe.title %></h1>
        <%!-- # FIXME: render markdown! --%>
        <p><%= @recipe.description %></p>
        <h2><%= gettext("Settings") %>:</h2>
        <.recipe_settings recipe={@recipe} />
      </article>
      <h2><%= gettext("Photos using this recipe") %>:</h2>
      <ul
        class="grid gap-4 grid-cols-2 md:grid-cols-4 lg:grid-cols-5 max-w-[1200px]"
        data-testid="recipe_list--photo"
      >
        <%= for %Photo{} = photo <- @recipe.photos do %>
          <PhotoComponent.render photo={photo} />
        <% end %>
      </ul>
    </div>
    """
  end

  defp recipe_settings(%{recipe: %Recipe{brand: "fujifilm"}} = assigns) do
    ~H"""
    <%= Phoenix.HTML.raw(render_map(@recipe.settings)) %>
    """
  end

  defp recipe_settings(%{recipe: %Recipe{brand: _unknown_brand}} = assigns) do
    ~H"""
    <i>
      <%= gettext("Unknown recipe brand, ask a developer to implement component") %>: <%= @recipe.brand %>
    </i>
    <i><%= gettext("Settings") %>: <%= inspect(@recipe.settings) %></i>
    """
  end

  defp render_map(map) when is_map(map) do
    content =
      map
      |> Enum.map(fn {key, value} ->
        "<tr>" <>
          "<td>#{key}</td>" <>
          "<td>" <>
          cond do
            is_map(value) -> render_map(value)
            is_list(value) -> render_list(value)
            true -> to_string(value)
          end <>
          "</td>" <>
          "</tr>"
      end)
      |> Enum.join()

    "<table>" <> content <> "</table>"
  end

  defp render_list(list) when is_list(list) do
    list
    |> Enum.map(fn item ->
      if is_map(item) do
        render_map(item)
      else
        to_string(item)
      end
    end)
    |> Enum.join(", ")
  end

  # TODO: DRY: dirty
  def handle_event("navigate_to", params, socket),
    do: FotohaeckerWeb.IndexLive.Home.handle_event("navigate_to", params, socket)
end
