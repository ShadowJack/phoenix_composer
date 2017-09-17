defmodule PhoenixComposer.Recipes.Recipe do
  @moduledoc """
  Define a behavoiur of a recipe.

  First ingredient in a recipe recieves one default arg: 
  path to the new project.

  All inner ingredients receive options from their parents, so that it's possible
  to use dependencies in inner ingredients.
  
  """
  alias PhoenixComposer.Ingredients.Ingredient
  
  defmacro __using__(_) do
    
  end

  def exec do
    
  end

  #TODO: 
  # 1. ask all questions before do block with passing currently buffered options
  # 2. exec commands from ingredient with all options in current scope
  # 3. exec inner block
  # 4. remove options from the opts state
end
