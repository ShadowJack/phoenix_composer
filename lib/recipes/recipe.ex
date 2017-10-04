defmodule PhoenixComposer.Recipes.Recipe do
  @moduledoc """
  Define a behavoiur of a recipe.

  First ingredient in a recipe recieves one default arg: 
  path to the new project.

  All inner ingredients receive options from their parents, so that it's possible
  to use dependencies in inner ingredients.
  
  """
  alias PhoenixComposer.Ingredients.Ingredient
  
  defmacro using(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro recipe(do: block) do
    quote do

      def exec(path) do
        # setup state agent
        Agent.start_link(fn -> {path, Keyword.new()} end, name: __MODULE__)

        unquote(block)
      end

    end
  end


  defmacro ingredient(mod, args \\ [], options \\ [], do_block \\ [])
  defmacro ingredient(mod, args, options, do: block) do
    quote do
      mod = unquote(mod)
      args = inject_phoenix_args(mod, unquote(args))

      scope_opts = Agent.get(__MODULE__, fn {_, scope_opts} -> scope_opts end)

      extended_scope_opts = Keyword.merge(scope_opts, unquote(options))

      # execute ingredient
      inner_scope_opts = mod.exec_ingredient(args, extended_scope_opts)

      # put updated scope opts into current state
      # so that child ingredients could use them
      Agent.update(__MODULE__, fn {path, _} -> {path, Keyword.merge(full_opts, inner_scope_opts)} end)

      # execute do block of the ingredient
      unquote(block)

      # restore current scope state
      Agent.update(__MODULE__, fn {path, _} -> {path, scope_opts} end)
    end
  end
  defmacro ingredient(mod, args, options, []) do
    quote do
      mod = unquote(mod)
      args = inject_phoenix_args(mod, unquote(args))

      opts = Agent.get(__MODULE__, fn {_, scope_opts} -> scope_opts end)
             |> Keyword.merge(unquote(options))

      # execute ingredient
      mod.exec_ingredient(args, opts)
    end
  end

  def inject_phoenix_args(PhoenixComposer.Ingredients.PhoenixComposer, args) do
    path = Agent.get(__MODULE__, fn {path, _} -> path end)
    [path | args]
  end
  def inject_phoenix_args(_mod, args) do
    args
  end
end
