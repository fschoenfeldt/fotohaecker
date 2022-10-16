defmodule FotohaeckerWeb.PhotoLive.FormComponent do
  use FotohaeckerWeb, :live_component

  alias Fotohaecker.Content

  @impl true
  def update(%{photo: photo} = assigns, socket) do
    changeset = Content.change_photo(photo)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"photo" => photo_params}, socket) do
    changeset =
      socket.assigns.photo
      |> Content.change_photo(photo_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"photo" => photo_params}, socket) do
    save_photo(socket, socket.assigns.action, photo_params)
  end

  defp save_photo(socket, :edit, photo_params) do
    case Content.update_photo(socket.assigns.photo, photo_params) do
      {:ok, _photo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Photo updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_photo(socket, :new, photo_params) do
    case Content.create_photo(photo_params) do
      {:ok, _photo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Photo created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
