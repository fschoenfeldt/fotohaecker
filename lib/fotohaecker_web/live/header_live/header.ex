defmodule FotohaeckerWeb.HeaderLive.Header do
  use FotohaeckerWeb, :live_component
  alias FotohaeckerWeb.HeaderLive.NavigationComponent

  def render(assigns) do
    ~H"""
    <header
      class="bg-transparent dark:bg-gray-800 shadow-sm dark:shadow-none dark:border-b dark:border-b-gray-600 relative p-2 md:p-4"
      id={@id}
    >
      <div class="max-w-6xl mx-auto">
        <section class="flex justify-between items-center gap-8">
          <.live_component module={NavigationComponent} id="navigation" current_user={@current_user} />
        </section>
      </div>
    </header>
    """
  end
end
