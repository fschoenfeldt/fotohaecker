defmodule FotohaeckerWeb.HeaderLive.Header do
  use FotohaeckerWeb, :live_component
  alias FotohaeckerWeb.HeaderLive.NavigationComponent

  # def mount(_params, _session, socket) do
  #   {:ok, assign(socket, :search, "")}
  # end

  def render(assigns) do
    ~H"""
    <header class="bg-[#17181b] relative p-2 md:p-4" id={@id}>
      <div class="max-w-6xl mx-auto">
        <section class="flex justify-between items-center gap-8">
          <a href={Routes.index_home_path(@socket, :home)} class="text-gray-100 text-xl">
            Fotohäcker
          </a>
          <.live_component module={NavigationComponent} id="navigation" current_user={@current_user} />
        </section>
      </div>
    </header>
    """
  end
end
