defmodule Recipes.RecipeStateTest do
  use ExUnit.Case, async: true

  alias PhoenixComposer.Recipes.RecipeState

  defmodule Tmp do
  end
  defmodule Tmp2 do
  end

  test "it's possible to get path from state" do
    RecipeState.start_link("path")
  
    assert "path" == RecipeState.get_path()
  end

  test "it's possible to put and get opts in current scope" do
    RecipeState.start_link("path")

    RecipeState.put_opts(Tmp, [a: 1, b: 2])
    RecipeState.put_opts(Tmp2, [c: 3])

    assert [c: 3, a: 1, b: 2] == RecipeState.get_opts()
  end

  test "it's possible to pop last opts from the state" do
    RecipeState.start_link("path")
    RecipeState.put_opts(Tmp, [a: 1, b: 2])
  
    RecipeState.pop_opts()
  
    assert [] == RecipeState.get_opts()
  end
end
