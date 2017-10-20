defmodule Ingredients.Fakes.TransparentFake do
  use PhoenixComposer.Ingredients.Ingredient

  @impl true
  def get_description(args, opts) do
    args 
    |> Enum.join("-") 
    |> Mix.shell.info()

    opts 
    |> Enum.map(fn {key, _value} -> to_string(key) end) 
    |> Enum.join("-") 
    |> Mix.shell.info()

    %Ingredient{args: args, opts: opts}
  end
end
