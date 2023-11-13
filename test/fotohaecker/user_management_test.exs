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

  describe "get_all/0" do
    test "gets all users" do
      expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
        [
          {
            :ok,
            %{
              email: "test@fschoenfeldt.de"
            }
          },
          {
            :ok,
            %{
              email: "test2@fschoenfeldt.de"
            }
          }
        ]
      end)

      actual = UserManagement.get_all()

      expected = [
        {
          :ok,
          %{
            email: "test@fschoenfeldt.de"
          }
        },
        {
          :ok,
          %{
            email: "test2@fschoenfeldt.de"
          }
        }
      ]

      assert actual == expected
    end
  end

  describe "delete/1" do
    test "deletes users" do
      expect(Fotohaecker.UserManagement.UserManagementMock, :delete, fn "user_id" ->
        :ok
      end)

      actual = UserManagement.delete("user_id")

      expected = :ok

      assert actual == expected
    end
  end

  describe "update/2" do
    test "updates user" do
      expect(Fotohaecker.UserManagement.UserManagementMock, :update, fn "user_id",
                                                                        %{
                                                                          email:
                                                                            "test@fschoenfeldt.de"
                                                                        } ->
        {
          :ok,
          %{
            email: "test@fschoenfeldt.de"
          }
        }
      end)

      actual = UserManagement.update("user_id", %{email: "test@fschoenfeldt.de"})

      expected = {
        :ok,
        %{
          email: "test@fschoenfeldt.de"
        }
      }

      assert actual == expected
    end
  end

  describe "add/1" do
    test "adds user" do
      expect(Fotohaecker.UserManagement.UserManagementMock, :add, fn "user_id" ->
        :ok
      end)

      actual = UserManagement.add("user_id")
      expected = :ok

      assert actual == expected
    end
  end

  describe "start_link/0" do
    test "starts link" do
      expect(Fotohaecker.UserManagement.UserManagementMock, :start_link, fn [] ->
        {:ok, :started}
      end)

      actual = UserManagement.start_link()
      expected = {:ok, :started}

      assert actual == expected
    end
  end
end
