defmodule FotohaeckerWeb.HeaderLive.Header do
  use FotohaeckerWeb, :live_component
  alias FotohaeckerWeb.HeaderLive.NavigationComponent

  def render(assigns) do
    ~H"""
    <header class="bg-transparent relative p-2 md:p-4" id={@id}>
      <div class="max-w-6xl mx-auto">
        <section class="flex justify-between items-center gap-8">
          <.live_component module={NavigationComponent} id="navigation" current_user={@current_user} />
        </section>
      </div>
    </header>
    """
  end
end
