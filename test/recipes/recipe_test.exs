Code.require_file "../recipes/fakes/recipe_fake.ex", __DIR__
Mix.shell(Mix.Shell.Process)

defmodule Recipes.RecipeTest do
  use ExUnit.Case, async: true

  alias Recipes.RecipeFake

  test "recipe executes all ingredients" do
    RecipeFake.exec("path")
    assert_receive {:mix_shell, :info, ["some arg-42"]}
    assert_receive {:mix_shell, :info, ["other arg"]}
  end

  test "inner ingredient recieves opts from the parent" do
    RecipeFake.exec("path")
    assert_receive {:mix_shell, :info, ["some arg-42"]}
    assert_receive {:mix_shell, :info, ["a-b"]}
    assert_receive {:mix_shell, :info, ["other arg"]}
    assert_receive {:mix_shell, :info, ["a-b"]}
  end

  test "outer ingredient don't receive opts of inner ingredients" do
    RecipeFake.exec("path")
    assert_receive {:mix_shell, :info, ["a-b"]}
    assert_receive {:mix_shell, :info, ["a-b"]}
    assert_receive {:mix_shell, :info, ["separate ingredient"]}
    refute_receive {:mix_shell, :info, ["a-b"]}
  end

end
