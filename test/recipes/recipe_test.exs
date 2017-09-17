Code.require_file "../recipes/fakes/recipe_fake.ex", __DIR__
Mix.shell(Mix.Shell.Process)

defmodule Recipes.RecipeTest do
  use ExUnit.Case, async: true

  alias PhoenixComposer.{Ingredients.Ingredient, Recipes.Recipe}


  test "first ingredient receives path argument" do
    Recipes.RecipeFake.exec("path")
    assert_receive {:mix_shell, :info, "path" <> _}
  end

  test "inner ingredient recieves opts from the parent" do
  end
end
