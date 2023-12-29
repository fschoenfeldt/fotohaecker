defmodule FotohaeckerWeb.PhotoControllerTest do
  use FotohaeckerWeb.ConnCase, async: true

  import Fotohaecker.ContentFixtures

  # alias Fotohaecker.Contents.Photo

  # @create_attrs %{
  #   title: "some title"
  # }
  # @update_attrs %{
  #   title: "some updated title"
  # }

  # @invalid_attrs %{title: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all photos", %{conn: conn} do
      conn = get(conn, ~p"/fh/api/content/photos")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "show" do
    test "renders photo by id", %{conn: conn} do
      photo_fixture(%{
        id: 1,
        title: "some title"
      })

      photo_fixture(%{
        id: 2,
        title: "another title"
      })

      actual =
        conn
        |> get(~p"/fh/api/content/photos/1")
        |> json_response(200)

      expected = %{
        "data" => %{
          "id" => 1,
          "links" => %{"html" => "http://localhost:4002/fh/en_US/photos/1"},
          "tags" => [],
          "title" => "some title",
          "urls" => %{
            "full" => "http://localhost:4002/uploads/some_file_name_preview.jpg",
            "raw" => "http://localhost:4002/uploads/some_file_name_og.jpg",
            "thumb1x" => "http://localhost:4002/uploads/some_file_name_thumb@1x.jpg",
            "thumb2x" => "http://localhost:4002/uploads/some_file_name_thumb@2x.jpg",
            "thumb3x" => "http://localhost:4002/uploads/some_file_name_thumb@3x.jpg"
          }
        }
      }

      assert actual == expected
    end

    # TODO proper 404 handling
    test "renders no result", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        conn
        |> get(~p"/fh/api/content/photos/1337")
        |> json_response(200)
      end
    end
  end

  describe "search" do
    test "finds photo", %{conn: conn} do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :search!, fn _term ->
        []
      end)

      photo_fixture(%{
        id: 1,
        title: "scottish coast",
        tags: ["scotland", "coast"]
      })

      photo_fixture(%{
        id: 2,
        title: "spain"
      })

      actual =
        conn
        |> get(~p"/fh/api/search/photos/scotland")
        |> json_response(200)

      expected = %{
        "data" => [
          %{
            "id" => 1,
            "links" => %{"html" => "http://localhost:4002/fh/en_US/photos/1"},
            "tags" => ["scotland", "coast"],
            "title" => "scottish coast",
            "urls" => %{
              "full" => "http://localhost:4002/uploads/some_file_name_preview.jpg",
              "raw" => "http://localhost:4002/uploads/some_file_name_og.jpg",
              "thumb1x" => "http://localhost:4002/uploads/some_file_name_thumb@1x.jpg",
              "thumb2x" => "http://localhost:4002/uploads/some_file_name_thumb@2x.jpg",
              "thumb3x" => "http://localhost:4002/uploads/some_file_name_thumb@3x.jpg"
            }
          }
        ]
      }

      assert actual == expected
    end

    test "returns empty list when empty string provided as input", %{conn: conn} do
      actual =
        conn
        |> get(~p"/fh/api/search/photos/%20")
        |> json_response(200)

      expected = %{
        "data" => []
      }

      assert actual == expected
    end
  end

  # describe "create photo" do
  #   test "renders photo when data is valid", %{conn: conn} do
  #     conn = post(conn, ~p"/fh/api/photos", photo: @create_attrs)
  #     assert %{"id" => id} = json_response(conn, 201)["data"]

  #     conn = get(conn, ~p"/fh/api/photos/#{id}")

  #     assert %{
  #              "id" => ^id,
  #              "title" => "some title"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post(conn, ~p"/fh/api/photos", photo: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "update photo" do
  #   setup [:create_photo]

  #   test "renders photo when data is valid", %{conn: conn, photo: %Photo{id: id} = photo} do
  #     conn = put(conn, ~p"/fh/api/photos/#{photo}", photo: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, ~p"/fh/api/photos/#{id}")

  #     assert %{
  #              "id" => ^id,
  #              "title" => "some updated title"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, photo: photo} do
  #     conn = put(conn, ~p"/fh/api/photos/#{photo}", photo: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete photo" do
  #   setup [:create_photo]

  #   test "deletes chosen photo", %{conn: conn, photo: photo} do
  #     conn = delete(conn, ~p"/fh/api/photos/#{photo}")
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, ~p"/fh/api/photos/#{photo}")
  #     end
  #   end
  # end

  # defp create_photo(_) do
  #   photo = photo_fixture()
  #   %{photo: photo}
  # end
end
