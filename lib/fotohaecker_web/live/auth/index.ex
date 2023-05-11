defmodule FotohaeckerWeb.AuthLive.Index do
  use FotohaeckerWeb, :live_view

  #  alias Ueberauth.Strategy.Helpers

  @impl true
  def mount(params, %{"callback_url" => callback_url} = session, socket) do
    IO.inspect(params)
    IO.inspect(session)

    {:ok,
     socket
     |> assign(callback_url: callback_url)
     |> assign(
       login_form: %{
         email: "",
         password: ""
       }
     )}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <h1>Log in with username / password</h1>

    <p>
      Enter the information to simulate the authentication.
    </p>

    <%= form_tag @callback_url, method: "post" do %>
      <fieldset>
        <legend>Authentication Information</legend>

        <label for="email">Email</label>
        <input type="email" name="email" id="email" required value={@login_form.email} />

        <label for="password">Password</label>
        <input type="password" name="password" id="password" required />

        <%!-- <label for="password_confirmation">Confirm Password</label>
        <input type="password" name="password_confirmation" id="password_confirmation" required /> --%>
      </fieldset>
      <%!--
      <fieldset>
        <legend>Additional Information</legend>

        <label for="first_name">First Name</label>
        <input type="text" name="first_name" id="first_name" value={@conn.params["first_name"]} />

        <label for="last_name">Last Name</label>
        <input type="text" name="last_name" id="last_name" value={@conn.params["last_name"]} />

        <label for="username">Username</label>
        <input type="text" name="username" id="username" value={@conn.params["username"]} />

        <label for="phone">Phone</label>
        <input type="tel" name="phone" id="phone" value={@conn.params["phone"]} />

        <label for="location">Location</label>
        <input type="text" name="location" id="location" value={@conn.params["location"]} />

        <label for="description">Description</label>
        <textarea name="description" id="description"><%= @conn.params["description"] %></textarea>
      </fieldset> --%>

      <input class="button" type="submit" value="Login" />
    <% end %>
    """
  end
end
