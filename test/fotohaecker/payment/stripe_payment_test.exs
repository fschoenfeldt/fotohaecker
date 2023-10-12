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

  describe "payment_account_id/1" do
    test "works with auth0 user with stripe id" do
      user = %{
        app_metadata: %{
          "stripe_id" => "stripe_id"
        }
      }

      actual = StripePayment.payment_account_id(user)
      expected = "stripe_id"

      assert actual == expected
    end

    test "works with auth0 user without stripe id" do
      user = %{
        app_metadata: %{
          "any_other_field" => "any_other_value"
        }
      }

      actual = StripePayment.payment_account_id(user)
      expected = nil

      assert actual == expected
    end

    test "works with nil as stripe id" do
      user = %{
        app_metadata: %{
          "stripe_id" => nil
        }
      }

      actual = StripePayment.payment_account_id(user)
      expected = nil

      assert actual == expected
    end
  end

  # TODO: can't be tested without mocked Stripe API Module
  @tag :skip
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
