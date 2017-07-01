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
    Mix.shell.info("PhoenixComposer v#{@version}")
  end

  def run(argv) do
    get_phx_version() |> run(argv)
  end

  @not_installed_error """
  Phoenix framework is not installed or can't be found
  To install please visit http://www.phoenixframework.org/docs/installation
  """

  @doc false
  # Check if Phoenix archive is installed
  # and return its version
  def get_phx_version(cmd \\ "phx.new") do
    Mix.Shell.Process.cmd("mix #{cmd} -v", print_app: false)
    receive do {:mix_shell, :run, [response]} -> 
      cond do
        response =~ "could not be found" -> 
          Mix.shell.error(@not_installed_error)
          :not_installed
        :otherwise -> 
          Regex.run(~r/Phoenix v(\d+\.\d+).*/, response) |> List.last()
      end
    end
  end

  defp run(:not_installed, _argv), do: nil
  defp run(phx_version, argv) do
    #TODO: parse args and put some of them into phx.new command
  end

end
