defmodule FotohaeckerWeb.UserLive.Index do
  use FotohaeckerWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    it works!
    """
  end
end