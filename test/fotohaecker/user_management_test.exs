defmodule Fotohaecker.UserManagementTest do
  use ExUnit.Case, async: true
  alias Fotohaecker.UserManagement
  alias Fotohaecker.UserManagement.UserManagementMock
  import Mox

  setup :verify_on_exit!

  describe "get/1" do
    test "gets user" do
      expect(UserManagementMock, :get, fn "user_id" -> nil end)
      UserManagement.get("user_id")
    end

    test "error when user not found" do
      expect(UserManagementMock, :get, fn "user_id" ->
        {:error, "error"}
      end)

      UserManagement.get("user_id")
    end
  end

  describe "get_all/0" do
    test "gets all users" do
      expect(UserManagementMock, :get_all, fn -> [] end)

      UserManagement.get_all()
    end
  end

  describe "delete/1" do
    test "deletes users" do
      expect(UserManagementMock, :delete, fn "user_id" -> :ok end)

      UserManagement.delete("user_id")
    end
  end

  describe "update/2" do
    test "updates user" do
      expect(UserManagementMock, :update, fn "user_id",
                                             %{
                                               email: "test@fschoenfeldt.de"
                                             } ->
        {:ok, %{email: "test@fschoenfeldt.de"}}
      end)

      UserManagement.update("user_id", %{email: "test@fschoenfeldt.de"})
    end
  end

  describe "add/1" do
    test "adds user" do
      expect(UserManagementMock, :add, fn "user_id" -> :ok end)

      UserManagement.add("user_id")
    end
  end

  describe "start_link/0" do
    test "starts link" do
      expect(UserManagementMock, :start_link, fn [] ->
        {:ok, :started}
      end)

      UserManagement.start_link()
    end
  end
end
