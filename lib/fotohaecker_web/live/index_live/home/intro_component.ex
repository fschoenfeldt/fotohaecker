defmodule FotohaeckerWeb.IndexLive.Home.IntroComponent do
  @moduledoc """
  Intro section on the home page.
  """

  use FotohaeckerWeb, :live_component

  alias FotohaeckerWeb.IndexLive.Home.UploadForm

  attr :photo_changeset, Ecto.Changeset, required: true
  attr :submission_params, :map, required: true
  attr :uploaded_photo, :any, required: true
  attr :uploads, :map, required: true

  def render(assigns) do
    ~H"""
    <div class="intro">
      <h1 class="">
        <%= gettext("Upload your photos, license-free.") %>
      </h1>
      <UploadForm.render
        photo_changeset={@photo_changeset}
        submission_params={@submission_params}
        uploaded_photo={@uploaded_photo}
        uploads={@uploads}
      />
    </div>
    """
  end
end
