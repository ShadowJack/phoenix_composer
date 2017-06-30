defmodule Mix.Tasks.Phx.Compose do
  @moduledoc """
  This task generates a new phoenix project
  and fills it with many useful libraries with your
  guidance.
  """
  use Mix.Task

  @version Mix.Project.config[:version]
  @shortdoc "Composes a new Phoenix application with PhoenixComposer v#{@version}"

  def run([version]) when version in ~w(-v --version) do
    Mix.Shell.IO.info("PhoenixComposer v#{@version}")
  end

  def run(_argv) do
    phx_version = get_phx_version!()
  end


  @not_installed_error """
  Phoenix framework is not installed or can't be found
  To install please visit http://www.phoenixframework.org/docs/installation
  """

  @doc false
  # Check if Phoenix archive is installed
  # and remember its version
  defp get_phx_version!() do
    Mix.Shell.Process.cmd("mix phx.new -v", print_app: false)
    receive do {:mix_shell, :run, [response]} -> 
      cond do
        response =~ "could not be found" -> 
          Mix.Shell.IO.error(@not_installed_error)
          throw "Phoenix is not found"
        :otherwise -> 
          Regex.run(~r/Phoenix v(\d+\.\d+).*/, response) |> List.last()
      end
    end
  end

end
