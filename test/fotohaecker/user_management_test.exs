defmodule Fotohaecker.UserManagementTest do
  use ExUnit.Case, async: true
  alias Fotohaecker.UserManagement
  import Mox

  setup :verify_on_exit!

  describe "get/1" do
    test "gets user" do
      expect(Fotohaecker.UserManagement.UserManagementMock, :get, fn "user_id" ->
        {
          :ok,
          %{
            email: "test@fschoenfeldt.de"
          }
        }
      end)

      actual = UserManagement.get("user_id")

      expected = {
        :ok,
        %{
          email: "test@fschoenfeldt.de"
        }
      }

      assert actual == expected
    end

    test "error when user not found" do
      expect(Fotohaecker.UserManagement.UserManagementMock, :get, fn "user_id" ->
        {:error, "error"}
      end)

      actual = UserManagement.get("user_id")

      expected = {:error, "error"}

      assert actual == expected
    end
  end
end
