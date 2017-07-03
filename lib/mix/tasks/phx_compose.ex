defmodule Mix.Tasks.Phx.Compose do
  @moduledoc """
  This task generates a new phoenix project
  and fills it with many useful libraries with your
  guidance.

  It expects a path of the new project as an argument.

      mix phx.compose PATH

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

  @phx_new "phx.new"
  @phoenix_new "phoenix.new"
  @not_installed_error """
  Phoenix framework is not installed or can't be found
  To install please visit http://www.phoenixframework.org/docs/installation
  """

  @doc false
  # Check if Phoenix archive is installed
  # and return its version
  def get_phx_version(task \\ @phx_new) do
    Mix.Shell.Process.cmd("mix #{task} -v", print_app: false)
    receive do {:mix_shell, :run, [response]} -> 
      cond do
        response =~ "could not be found" && task == @phx_new -> 
          # Try older version of Phoenix
          get_phx_version(@phoenix_new)

        response =~ "could not be found" -> 
          Mix.shell.error(@not_installed_error)
          :not_installed

        :otherwise -> 
          Regex.run(~r/Phoenix v(\d+\.\d+).*/, response) 
          |> List.last() 
          |> String.to_float()
      end
    end
  end

  defp run(:not_installed, _argv), do: nil
  defp run(phx_version, argv) do
    case OptionParser.parse(argv) do
      {_, [], _}  -> Mix.Tasks.Help.run(["phx.compose"])
      {opts, [path | _], _} -> generate_new_project(path, phx_version, opts)
    end
  end

  def generate_new_project(path, phx_version, _opts) do
    results = 
      get_phx_new_opts(path, phx_version)
      |> Enum.map(&ask_user(&1))
    
    #TODO: Ask for options and save them in struct
    #TODO: Call phx.new
  end

  @doc """
  Build options for phoenix.new or phx.new(if installed) task.
  """
  def get_phx_new_opts(path, phx_version) do
    default_app = Path.basename(path)
    default_module = Macro.camelize(default_app)
    opts = [
      {:app, "Enter the name of the OTP application.\nThe default is: \"#{default_app}\"", default_app},
      {:module, "Enter the name of the base module.\nThe default is: \"#{default_module}\"", default_module},
      {:no_ecto, "Do NOT use ecto in your project?", false},
      {:database, "Specify the database adapter for ecto. Values can be `postgres`, `mysql`. Leave empty to use `postgres`", "postgres"},
      {:binary_id, "Use `binary_id` as primary key type in Ecto schemas?", false},
      {:no_brunch, "Do NOT use brunch in yout project?", false},
      {:no_html, "Do NOT generate html views?", false}
    ]

    if phx_version < 1.3 do
      opts
    else
      umbrella = {:umbrella, "Do you want to generate an umbrella project, with one applicaton for your domain, and a second one for the web interface?", false}
      [umbrella | opts]
    end
  end

  @doc """
  Asks user a new question depending on 
  the default value of the answer.
  
  If default answer is string then question is prompted.
  If default answer is bool then [Yn] answer is expected.
  """
  def ask_user({name, description, default}) when is_binary(default) do
    case Mix.shell.prompt(description) do
      ""       -> {name, default}
      response -> {name, response}
    end

  end
  def ask_user({name, description, default}) when is_boolean(default) do
    response = Mix.shell.yes?(description)
    {name, response}
  end

end
