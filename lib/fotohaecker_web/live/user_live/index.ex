defmodule FotohaeckerWeb.UserLive.Index do
  alias Fotohaecker.UserManagement
  use FotohaeckerWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    current_user = UserManagement.get(socket.assigns.current_user.id)

    socket =
      case current_user do
        {:ok, user} ->
          assign(socket, :current_user, user)

        error ->
          assign(socket, :error, error)
      end

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div id="user" class="max-w-6xl mx-2 md:mx-auto space-y-2 pt-2">
      <h1 class="dark:text-gray-100"><%= gettext("Your Account") %></h1>

      <.account_info error={Map.get(assigns, :error)} current_user={Map.get(assigns, :current_user)} />
      <.donation error={Map.get(assigns, :error)} current_user={Map.get(assigns, :current_user)} />
      <.delete_logout socket={@socket} current_user={Map.get(assigns, :current_user)} />
    </div>
    """
  end

  defp delete_logout(assigns) do
    ~H"""
    <div class="flex space-x-4">
      <.form
        for={%{}}
        method="post"
        action={
          FotohaeckerWeb.Router.Helpers.auth_path(
            @socket,
            :logout
          )
        }
      >
        <button type="submit" class="btn">
          <%= gettext("logout") %>
        </button>
      </.form>

      <.form
        for={%{}}
        method="post"
        action={
          FotohaeckerWeb.Router.Helpers.auth_path(
            @socket,
            :delete_account,
            Gettext.get_locale(FotohaeckerWeb.Gettext)
          )
        }
      >
        <button type="submit" class="btn btn--red">
          <%= gettext("Delete Account") %>
        </button>
      </.form>
    </div>
    """
  end

  attr(:current_user, :any)
  attr(:error, :any)

  defp account_info(%{error: error} = assigns) when is_tuple(error) do
    ~H"""
    <p class="font-bold dark:text-gray-100">
      There was an error fetching your user information: <%= @error["statusCode"] %>: <%= @error[
        "message"
      ] %>
    </p>
    """
  end

  defp account_info(assigns) do
    ~H"""
    <dl class="space-y-2">
      <dt class="font-bold dark:text-gray-100"><%= gettext("Name/Email") %></dt>
      <dd class="dark:text-gray-100"><%= @current_user.email %></dd>
      <dt class="font-bold dark:text-gray-100"><%= gettext("Nickname") %></dt>
      <dd class="dark:text-gray-100"><%= @current_user.nickname %></dd>
      <dt class="font-bold dark:text-gray-100"><%= gettext("Your Profile Link") %></dt>
      <dd class="dark:text-gray-100">
        <a href={user_route(@current_user.id)} class="break-words">
          <%= user_url(@current_user.id) %>
        </a>
      </dd>
    </dl>
    """
  end

  defp donation(%{error: error} = assigns) when is_tuple(error) do
    ~H"""

    """
  end

  defp donation(assigns) do
    ~H"""
    <div class="rounded border border-green-700 text-white space-y-4">
      <div class="flex space-x-2 items-center bg-green-700 p-2">
        <Heroicons.currency_euro mini class="h-8 w-8 fill-white" />
        <h2 class="text-white font-sans">
          <%= gettext("Donations") %>
          <span class="text-white text-base ms-2">
            <%= gettext("Note: Donations are for demonstrative purposes only!") %>
          </span>
        </h2>
      </div>
      <div class="px-4 pb-4 space-y-4">
        <%= if Fotohaecker.Payment.has_stripe_account?(@current_user) do %>
          <%= with is_fully_onboarded? <- Fotohaecker.Payment.is_fully_onboarded?(@current_user) do %>
            <p class="dark:text-gray-100"><%= gettext("Steps to enable donations:") %></p>
            <ol class="list-inside">
              <li class="flex items-center gap-1 dark:text-gray-100">
                <Heroicons.check_circle mini class="h-6 w-6 inline fill-green-700" />
                <%= gettext("Stripe Account created") %>
                <button
                  type="button"
                  phx-click="delete_stripe_account"
                  class="btn btn--sm btn--red ms-1"
                >
                  <%= gettext("Delete Stripe Account") %>
                </button>
              </li>
              <li :if={is_fully_onboarded?} class="flex items-center gap-1 dark:text-gray-100">
                <Heroicons.check_circle mini class="h-6 w-6 inline fill-green-700" />
                <%= gettext("onboarding completed") %>
              </li>
              <li :if={!is_fully_onboarded?} class="flex items-center gap-1">
                <Heroicons.x_circle mini class="h-6 w-6 inline fill-red-700" />
                <%= gettext("onboarding not completed.") %>
                <%= with {:ok, %{url: url}} <- Fotohaecker.Payment.create_onboarding(@current_user) do %>
                  <.external_link url={url} text={gettext("Click here to complete onboarding.")} />
                <% end %>
              </li>
            </ol>
            <%!-- <details>
              <code>
                <%= with {:ok, stripe_account} <- Fotohaecker.Payment.retrieve(@current_user.app_metadata["stripe_id"]) do %>
                  <%= inspect(stripe_account) %>
                <% end %>
              </code>
            </details> --%>
            <p :if={is_fully_onboarded?} class="dark:text-gray-100">
              <%= case Fotohaecker.Payment.create_login_link(@current_user.app_metadata["stripe_id"]) do %>
                <% {:ok, %Stripe.LoginLink{url: url}} -> %>
                  <%= gettext("You're ready to receive donations!") %>
                  <.external_link
                    url={url}
                    text={gettext("Click here to open your donation dashboard.")}
                  />
                <% {:error, %{message: message}} -> %>
                  <%= gettext("There is a problem with your Stripe Account: %{message}", %{
                    message: message
                  }) %>
              <% end %>
            </p>
          <% end %>
        <% else %>
          <p>
            <%= gettext(
              "You have not yet created a Stripe account. Please create one to receive donations."
            ) %>
          </p>
          <button type="button" phx-click="create_stripe_account" class="btn btn--green">
            <%= gettext("Create Stripe Account & setup donations") %>
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  attr(:url, :string, required: true)
  attr(:text, :string, required: true)
  attr(:class, :string, default: "")
  attr(:class_icon, :string, default: "")

  # TODO: external link component, move this to a component
  def external_link(assigns) do
    ~H"""
    <.link href={@url} target="_blank" class={@class}>
      <Heroicons.arrow_top_right_on_square
        mini
        class={[@class_icon, "h-4 w-4 inline fill-blue-700 dark:fill-blue-400"]}
      />
      <%= @text %>
    </.link>
    """
  end

  def handle_event("create_stripe_account", _params, socket) do
    case Fotohaecker.Payment.create_account(socket.assigns.current_user.id) do
      {:ok, %Stripe.Account{}} ->
        {:ok, updated_user} = UserManagement.get(socket.assigns.current_user.id)

        {:noreply,
         socket
         |> put_flash(:info, gettext("Stripe Account successfully created!"))
         |> assign(:current_user, updated_user)}

      {:error, %{message: message}} ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end

  def handle_event("delete_stripe_account", _params, socket) do
    case Fotohaecker.Payment.delete_account(socket.assigns.current_user.id) do
      {:ok, _deleted_account} ->
        {:ok, updated_user} = UserManagement.get(socket.assigns.current_user.id)

        {:noreply,
         socket
         |> put_flash(:info, gettext("Stripe Account successfully deleted!"))
         |> assign(:current_user, updated_user)}

      {:error, %{message: message}} ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end
end
