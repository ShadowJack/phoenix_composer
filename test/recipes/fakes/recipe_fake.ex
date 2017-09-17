Code.require_file "../../../lib/recipes/recipe.ex", __DIR__

defmodule Recipes.RecipeFake do
  use PhoenixComposer.Recipes.Recipe
  alias Ingredients.Fakes.TransparentFake

  # ingredient TransparentFake, args: ["some arg", 42] do
  # end
  # 
  # ingredient Ingredients.IngredientStub, args: ["some arg", 42] do
  # end
end

