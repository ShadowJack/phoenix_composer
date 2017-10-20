Code.require_file "../mix_helper.exs", __DIR__

defmodule Ingredients.DepsTest do
  use ExUnit.Case, async: true

  import MixHelper

  alias PhoenixComposer.Ingredients.Ingredient
  
  test "adds deps to mix.exs" do
    in_tmp(get_tmp_folder(), fn ->
      File.mkdir!("project")
      File.write!("project/mix.exs", mixfile_contents(), [:write])

      Ingredient.add_deps({:test_dep, "~> 1.0"}, [base_path: "project"])

      assert_file("project/mix.exs", "{:test_dep, \"~> 1.0\"}")
    end)
  end
end
