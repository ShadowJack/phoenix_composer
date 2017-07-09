defmodule Mix.Tasks.Phx.Compose do
  @moduledoc """
  This task generates a new phoenix project
  and fills it with many useful libraries with your
  guidance.

  It expects a path of the new project as an argument.

      mix phx.compose PATH

  """
  use Mix.Task
  alias PhoenixComposer.Option

  @version Mix.Project.config[:version]
  @shortdoc "Composes a new Phoenix application with PhoenixComposer v#{@version}"

  @spec run([String.t]) :: any
  def run([version]) when version in ~w(-v --version) do
    Mix.shell.info("PhoenixComposer v#{@version}")
  end
  def run(argv) do
    case OptionParser.parse(argv) do
      {_, [], _}  -> Mix.Tasks.Help.run(["phx.compose"])
      {opts, args, _} -> 
        #TODO: extract some info from opts
        PhoenixComposer.Ingredients.Phoenix.run(args, opts)
    end
  end

end
