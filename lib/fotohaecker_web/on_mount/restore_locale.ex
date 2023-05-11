defmodule FotohaeckerWeb.OnMount.RestoreLocale do
  @moduledoc """
  Ensures that the current locale is available in gettext
  source: https://hexdocs.pm/phoenix_live_view/using-gettext.html
  """

  def on_mount(:default, %{"locale" => locale} = _params, _session, socket) do
    Gettext.put_locale(FotohaeckerWeb.Gettext, locale)
    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket) do
    {:cont, socket}
  end
end
