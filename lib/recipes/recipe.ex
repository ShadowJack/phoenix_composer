defmodule PhoenixComposer.Recipes.Recipe do
  @moduledoc """
  Define a behavoiur of a recipe.

  First ingredient in a recipe recieves one default arg: 
  path to the new project.

  All inner ingredients receive options from their parents, so that it's possible
  to use dependencies in inner ingredients.
  """

  alias PhoenixComposer.Recipes.RecipeState

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc """
  Defines a main scope of the recipe. 
  All ingredients should be placed inside.
  """
  defmacro recipe(do: block) do
    quote do

      def exec(path) do
        RecipeState.start_link(path)

        unquote(block)
      end

    end
  end


  @doc """
  Adds a new ingredient into the recipe.

  The following options are supported:

    * `:args` - command line arguments to be passed inside the ingredient
    * `:opts` - command line opts to be passed inside the ingredient

  Optional do block can be provided, so that ingredients defined inside it will receive
  opts of the parents. It may be required if one ingredient somehow depends on opts of the other one.
  
  Example:

  ```
  defmodule MyRecipe do
    use PhoenixComposer.Recipes.Recipe

    alias PhoenixComposer.Ingredients.Phoenix

    recipe do
      ingredient Phoenix, args: ["new_project"], opts: [umbrella: true] do
        ingredient MyIngredient, opts: [some_opt: "value"]
      end
    end
  end
  ```
  """
  defmacro ingredient(mod, options \\ []) do
    {block, options} = Keyword.pop(options, :do)
    quote do: ingredient(unquote(mod), unquote(options), do: unquote(block))
  end
  defmacro ingredient(mod, options, do: nil) do
    quote do
      mod = unquote(mod)
      {args, opts} = parse_options(unquote(options))
      args = inject_phoenix_args(mod, args)
  
      opts = RecipeState.get_opts() |> Keyword.merge(opts)
  
      # execute ingredient
      mod.exec_ingredient(args, opts)
    end
  end
  defmacro ingredient(mod, options, do: block) do
    quote do
      mod = unquote(mod)
      {args, opts} = parse_options(unquote(options))

      args = inject_phoenix_args(mod, args)

      scope_opts = RecipeState.get_opts() |> Keyword.merge(opts)

      # execute ingredient
      ingredient_opts = mod.exec_ingredient(args, scope_opts)

      # put updated scope opts into current state
      # so that child ingredients could use them
      RecipeState.put_opts(mod, ingredient_opts)

      # execute do block of the ingredient
      unquote(block)

      # restore current scope state
      RecipeState.pop_opts()
    end
  end

  ## Helpers
  #

  @valid_ingredient_options [:args, :opts]

  @spec parse_options(Keyword.t) :: {[], Keyword.t}
  def parse_options(options) do
    @valid_ingredient_options
    |> Enum.map(fn key -> Keyword.get(options, key, []) end)
    |> List.to_tuple()
  end

  @spec inject_phoenix_args(atom, []) :: []
  def inject_phoenix_args(PhoenixComposer.Ingredients.PhoenixComposer, args) do
    path = RecipeState.get_path()
    [path | args]
  end
  def inject_phoenix_args(_mod, args) do
    args
  end
end
