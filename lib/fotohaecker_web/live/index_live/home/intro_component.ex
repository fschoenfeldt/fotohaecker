defmodule FotohaeckerWeb.IndexLive.Home.IntroComponent do
  @moduledoc """
  Intro section on the home page.
  """

  use FotohaeckerWeb, :live_component

  alias FotohaeckerWeb.IndexLive.Home.UploadForm

  def render(assigns) do
    ~H"""
    <div class="intro">
      <h1 class="">
        <%= gettext("Upload your photos, license-free.") %>
      </h1>
      <UploadForm.render
        photo_changeset={@photo_changeset}
        submission_params={@submission_params}
        uploads={@uploads}
      />
    </div>
    """
  end
end
