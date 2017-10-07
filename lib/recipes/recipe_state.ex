defmodule PhoenixComposer.Recipes.RecipeState do
  use Agent

  def start_link(path) do
    Agent.start_link(fn -> {path, []} end, name: __MODULE__)
  end

  def put_opts(mod, new_opts) do
    Agent.update(__MODULE__, fn {path, opts} -> {path, [{mod, new_opts} | opts]} end)
  end

  def get_opts() do
    Agent.get(__MODULE__, fn {_, opts} -> opts end)
    |> Enum.reduce([], fn {_, opts}, acc -> Keyword.merge(acc, opts) end)
  end

  def pop_opts() do
    Agent.update(__MODULE__, fn {path, opts} ->
      case opts do
        [] -> {path, []}
        [_head | tail] -> {path, tail}
      end
    end)
  end

  def get_path() do
    Agent.get(__MODULE__, fn {path, _} -> path end)
  end
end
