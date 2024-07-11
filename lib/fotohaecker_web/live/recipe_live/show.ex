defmodule FotohaeckerWeb.RecipeLive.Show do
  use FotohaeckerWeb, :live_view

  alias Fotohaecker.Content.Photo
  alias Fotohaecker.Content.Recipe
  alias Fotohaecker.Content
  alias FotohaeckerWeb.IndexLive.Home.PhotoComponent

  defmodule RecipeNotFoundError do
    defexception message: dgettext("errors", "recipe not found"), plug_status: 404
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    case Content.get_recipe(id, [
           :photos
         ]) do
      nil ->
        raise RecipeNotFoundError
        {:noreply, socket}

      %Recipe{description: nil} = recipe ->
        {
          :noreply,
          assign(socket, recipe: recipe, description_as_ast: nil)
        }

      recipe ->
        {:ok, description_as_ast, _whatever} = Earmark.as_html(recipe.description)

        {
          :noreply,
          assign(socket, recipe: recipe, description_as_ast: description_as_ast)
        }
    end
  end

  # TODO: DRY: date function
  def render(assigns) do
    ~H"""
    <div class="space-y-2 p-4">
      <%= with post_date <- Date.to_iso8601(@recipe.inserted_at) do %>
        <article
          class="prose"
          x-data={"
        {
          inserted_at: new Date('#{post_date}').toLocaleDateString('#{FotohaeckerWeb.Gettext |> Gettext.get_locale() |> String.replace("_", "-")}', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
          })
        }
        "}
        >
          <h1><%= gettext("Recipe") %>: <%= @recipe.title %></h1>
          <p>
            <%= gettext("Posted on") %>
            <span x-text="inserted_at"><%= post_date %></span>,
            <.user_profile_link recipe={@recipe} />
          </p>
          <p><%= Phoenix.HTML.raw(@description_as_ast) %></p>
          <h2><%= gettext("Settings") %>:</h2>
          <.recipe_settings recipe={@recipe} />
        </article>
      <% end %>
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
      Enum.map_join(map, fn {key, value} ->
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

    "<table>" <> content <> "</table>"
  end

  defp render_list(list) when is_list(list) do
    Enum.map_join(list, ",", fn item ->
      if is_map(item) do
        render_map(item)
      else
        to_string(item)
      end
    end)
  end

  # TODO: DRY: dirty
  def handle_event("navigate_to", params, socket),
    do: FotohaeckerWeb.IndexLive.Home.handle_event("navigate_to", params, socket)
end
