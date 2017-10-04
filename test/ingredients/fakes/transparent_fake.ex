defmodule Ingredients.Fakes.TransparentFake do
  use PhoenixComposer.Ingredients.Ingredient

  @impl
  def get_description(args, opts) do
    args 
    |> Enum.join("-") 
    |> Mix.shell.info()

    opts 
    |> Enum.map(fn {key, value} -> to_string(key) end) 
    |> Enum.join("-") 
    |> Mix.shell.info()

    %Ingredient{args: args, opts: opts}
  end

  @impl
  def cmds(description) do
    :ok
  end

  @impl
  def exec(description) do
    :ok
  end
end
