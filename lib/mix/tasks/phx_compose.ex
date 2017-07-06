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

  @typep answer :: String.t | boolean

  @spec run([String.t]) :: any
  def run([version]) when version in ~w(-v --version) do
    Mix.shell.info("PhoenixComposer v#{@version}")
  end
  def run(argv) do
    get_phx_version() |> do_run(argv)
  end

  @spec do_run(:not_installed | float, [String.t]) :: any
  defp do_run(:not_installed, _argv), do: nil
  defp do_run(phx_version, argv) do
    case OptionParser.parse(argv) do
      {_, [], _}  -> Mix.Tasks.Help.run(["phx.compose"])
      {opts, [path | _], _} -> generate_new_project(path, phx_version, opts)
    end
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
  @spec get_phx_version(String.t) :: :not_installed | float
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


  @spec generate_new_project(String.t, float, []) :: any
  def generate_new_project(path, phx_version, _opts) do
    results = 
      get_phx_new_opts(path, phx_version)
      |> Enum.reduce([], &(ask_user/2))
    
    #TODO: Ask for options and save them in struct
    #TODO: Call phx.new
  end


  @doc """
  Build options for phoenix.new or phx.new(if installed) task.
  """
  @spec get_phx_new_opts(String.t, float) :: [Option.t]
  def get_phx_new_opts(path, phx_version) do
    default_app = Path.basename(path)
    default_module = Macro.camelize(default_app)
    opts = [
      %Option{name: :app,       default: default_app,      description: "Enter the name of the OTP application.\nThe default is: \"#{default_app}\"\n"},
      %Option{name: :module,    default: default_module,   description: "Enter the name of the base module.\nThe default is: \"#{default_module}\"\n"},
      %Option{name: :no_ecto,   default: false,            description: "Do NOT use ecto in your project?"},
      %Option{name: :database,  default: "postgres",       description: "Specify the database adapter for ecto. Values can be `postgres`, `mysql`.\nThe default is: `postgres`\n", deps: [no_ecto: false]},
      %Option{name: :binary_id, default: false,            description: "Use `binary_id` as primary key type in Ecto schemas?", deps: [no_ecto: false]},
      %Option{name: :no_brunch, default: false,            description: "Do NOT use brunch in yout project?"},
      %Option{name: :no_html,   default: false,            description: "Do NOT generate html views?"}
    ]

    if phx_version < 1.3 do
      opts
    else
      umbrella = 
        %Option{name: :umbrella, default: false, description: "Do you want to generate an umbrella project, with one applicaton for your domain, and a second one for the web interface?"}
      [umbrella | opts]
    end
  end


  @doc """
  Asks user a new question depending on 
  the default value of the answer.
  
  If default answer is string then question is prompted.
  If default answer is bool then [Yn] answer is expected.
  """
  @spec ask_user(Option.t, [{atom, answer}]) :: [{atom, answer}]
  def ask_user(option, answers) do
    if should_ask?(answers, option.deps) do
      do_ask_user(option, answers)
    else
      answers
    end
  end

  # Should ask the new question only if all its dependencies are positive
  @spec should_ask?([{atom, answer}], [{atom, boolean}]) :: boolean
  defp should_ask?(prev_answers, deps) do
    Enum.all?(prev_answers, fn {name, value} -> 
      case Enum.find(deps, fn {dep_name, _} -> dep_name == name end) do
        {_, dep_value} -> dep_value == value
        nil -> true
      end
    end)
  end

  @spec do_ask_user(%Option{default: String.t}, [{atom, answer}]) :: [{atom, answer}]
  defp do_ask_user(%Option{default: default} = option, answers) when is_binary(default) do
    case Mix.shell.prompt(option.description) do
      ""       -> [{option.name, default} | answers]
      value -> [{option.name, value} | answers]
    end
  end
  @spec do_ask_user(%Option{default: boolean}, [{atom, answer}]) :: [{atom, answer}]
  defp do_ask_user(%Option{default: default} = option, answers) when is_boolean(default) do
    value = Mix.shell.yes?(option.description)
    [{option.name, value} | answers]
  end

end
