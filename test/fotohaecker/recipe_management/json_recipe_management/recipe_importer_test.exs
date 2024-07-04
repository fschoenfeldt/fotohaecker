defmodule Fotohaecker.RecipeManagement.JsonRecipeManagement.JsonRecipeImporterTest do
  use Fotohaecker.DataCase, async: false
  import Mox

  setup :verify_on_exit!

  alias Fotohaecker.RecipeManagement.JsonRecipeManagement.JsonRecipeImporter

  setup do
    :ok
  end

  test "importing recipes from a directory" do
    # Define a test directory with sample JSON files
    test_directory = "test/support/fixtures/content/recipes/valid"

    # Run the import function
    [
      {:ok,
       %{
         file_path: file_path,
         recipe: {
           :ok,
           %Fotohaecker.Content.Recipe{
             title: title,
             user_id: user_id,
             settings: settings
           }
         }
       }}
    ] = JsonRecipeImporter.import_recipes_from_directory(test_directory)

    assert file_path == "test/support/fixtures/content/recipes/valid/valid_recipe.json"
    assert title == "Valid Recipe Title"
    assert user_id == "auth0|1234567890"

    assert settings == %{
             "base_simulation" => "Classic Negative",
             "compatible" => ["x_trans_iv", "x_trans_v"]
           }
  end

  test "logs error when importing invalid JSON" do
    # Define a test directory with sample JSON files
    test_directory = "test/support/fixtures/content/recipes/invalid"

    # Run the import function
    actual = JsonRecipeImporter.import_recipes_from_directory(test_directory)

    expected = [
      error: %{
        error: {:error, %Jason.DecodeError{position: 0, token: nil, data: ""}},
        file_path: "test/support/fixtures/content/recipes/invalid/invalid_recipe.json"
      }
    ]

    assert actual == expected
  end
end
