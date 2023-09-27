defmodule Fotohaecker.Payment do
  @moduledoc """
  Payment within Fotohaecker.
  """

  #   Glückwunsch, Sie haben Ihren Antrag fast abgeschlossen!
  # Nachdem sich Ihre Nutzer/innen bei Stripe angemeldet haben, werden sie auf eine Seite Ihrer Wahl weitergeleitet (Standardeinstellung). Stellen Sie sicher, dass Sie den Test URI in Ihren Anwendungseinstellungen auf eine Seite weiterleiten, die für Ihren eigenen Server Sinn ergibt.
  # Um den Erhalt eines access_token für Ihr Nutzerkonto abzuschließen, müssen Sie eine zusätzliche API-Anfrage mit dem von uns zurückgegebenen Autorisierungscode durchführen. Der Code wird ac_Oi0C7Ur2lm4RwxCFH2ml2i5PzDPQeoKd direkt von den GET-Parametern der Weiterleitung übernommen.
  # Probieren Sie es beispielsweise mit dieser curl-Anfrage. Beachten Sie, dass Sie YOUR_SECRET_KEY mit dem Test Sicherheitsschlüssel des Anwendungsbesitzers ersetzen müssen.
  # curl -X POST https://connect.stripe.com/oauth/token \
  # -d client_secret=YOUR_SECRET_KEY \
  # -d code=ac_Oi0C7Ur2lm4RwxCFH2ml2i5PzDPQeoKd \
  # -d grant_type=authorization_code
  # Sie müssen dies programmatisch durchführen (wir empfehlen eine OAuth-2.0-Bibliothek einer Drittpartei). Sehen Sie sich unsere OAuth-Anleitung an, um eine genauere Erläuterung zu erhalten! Oder gehen Sie zurück zu unserer Anleitung zum Loslegen, um einen Eindruck davon zu erhalten, welche Möglichkeiten Sie haben, nachdem sich Ihre Nutzer/innen bei Stripe angemeldet haben.

  # accountid: ac_Oi0C7Ur2lm4RwxCFH2ml2i5PzDPQeoKd

  @photographer_account_id "acct_1NuthYPxCsgTBxpz"

  # def authorize_url do
  #   Stripe.Connect.OAuth.authorize_url(%{
  #     stripe_user: %{
  #       "email" => "frederikschoenfeldt+stripetest@gmail.com",
  #       "url" => "https://fschoenf.uber.space/fh/en_US/user/auth0%7C649d5a069846429298463b73",
  #       "country" => "DE"
  #     }
  #   })
  # end

  def create_account(auth0_user_id \\ "auth0|6513ef7d56ab5fc22ace2926") do
    {:ok, auth0_user} = Fotohaecker.UserManagement.get(auth0_user_id)

    Stripe.Account.create(%{
      type: "express",
      email: auth0_user.email,
      metadata: %{
        "auth0_user_id" => auth0_user_id
      }
    })
  end

  def create_onboarding(stripe_account_id \\ @photographer_account_id) do
    Stripe.AccountLink.create(%{
      account: stripe_account_id,
      refresh_url: "https://example.com/reauth",
      return_url: "https://example.com/return",
      type: "account_onboarding"
    })
  end

  def retrieve(account_id \\ @photographer_account_id) do
    Stripe.Account.retrieve(account_id)
  end

  # def checkout(account_id, price_id \\ "price_1NusQeLrossD7mFggNUhM8KQ") do
  #   Stripe.Session.create(%{
  #     # TODO urls
  #     success_url: "https://example.com",
  #     cancel_url: "https://example.com",
  #     mode: "payment",
  #     line_items: [
  #       %{
  #         price: price_id,
  #         quantity: 1
  #       }
  #     ]
  #   })
  # end
end
