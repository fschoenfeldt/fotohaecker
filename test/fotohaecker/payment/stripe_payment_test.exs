defmodule Fotohaecker.Payment.StripePaymentTest do
  use Fotohaecker.DataCase, async: true
  alias Fotohaecker.Payment.StripePayment

  describe "has_payment_account?/1" do
    test "returns true with auth0 user with stripe id in metadata" do
      user = %{
        app_metadata: %{
          "stripe_id" => "stripe_id"
        }
      }

      expected = true
      actual = StripePayment.has_payment_account?(user)

      assert actual == expected
    end

    test "returns false withouth auth0 user with stripe id in metadata" do
      user = %{
        any_other_field: "any_other_value",
        app_metadata: %{
          "any_other_field" => "any_other_value"
        }
      }

      expected = false
      actual = StripePayment.has_payment_account?(user)

      assert actual == expected
    end

    test "returns false with nil as stripe_id in metadata" do
      user = %{
        app_metadata: %{
          "stripe_id" => nil
        }
      }

      expected = false
      actual = StripePayment.has_payment_account?(user)

      assert actual == expected
    end
  end

  describe "checkout/1" do
    test "returns a session" do
      user = %{
        app_metadata: %{
          "stripe_id" => "stripe_id"
        }
      }

      expected = {:ok, %{}}
      actual = StripePayment.checkout(user)

      assert actual == expected
    end
  end
end
