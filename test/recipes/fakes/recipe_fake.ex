Code.require_file "../../ingredients/fakes/transparent_fake.ex", __DIR__

defmodule Recipes.RecipeFake do
  use PhoenixComposer.Recipes.Recipe
  alias Ingredients.Fakes.TransparentFake

  recipe do
    ingredient TransparentFake, args: ["some arg", 42], opts: [a: 1, b: 2] do
      ingredient TransparentFake, args: ["other arg"]
    end

    ingredient TransparentFake, args: ["separate ingredient"]
  end

end

