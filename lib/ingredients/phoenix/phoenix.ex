defmodule PhoenixComposer.Ingredients.Phoenix do
  @moduledoc """
  The main ingredient that runs phoenix.new or phx.new 
  depending on version of Phoenix installed
  """

  use PhoenixComposer.Ingredients.Ingredient

  @phx_new "phx.new"
  @phoenix_new "phoenix.new"
  @not_installed_error """
  Phoenix framework is not installed or can't be found
  To install please visit http://www.phoenixframework.org/docs/installation
  """


  @doc """
  Implementation for the main function of Ingredient
  """
  @spec run([String.t], [{atom, any}]) :: none
  def run([], _), do: Mix.Tasks.Help.run(["phx.compose"])
  def run([path | _], opts) do
    case get_phx_version() do
      :not_installed -> Mix.shell.error(@not_installed_error)
      phx_version    -> generate_new_project(path, phx_version, opts)
    end
  end


  @doc """
  Generate a new phoenix project.
  """
  @spec generate_new_project(String.t, float, []) :: any
  def generate_new_project(path, phx_version, _opts) do
    results = 
      get_ingredient_opts([path, phx_version])
      |> Enum.reduce([], &(ask_user/2))
    #TODO: Call phx.new
  end


  @doc """
  Check if Phoenix archive is installed
  and return its version.
  """
  @spec get_phx_version(String.t) :: :not_installed | float
  def get_phx_version(task \\ @phx_new) do
    Mix.Shell.Process.cmd("mix #{task} -v", print_app: false)
    receive do {:mix_shell, :run, [response]} -> 
      cond do
        response =~ "could not be found" && task == @phx_new -> 
          # Try older version of Phoenix
          get_phx_version(@phoenix_new)

        response =~ "could not be found" -> 
          :not_installed

        :otherwise -> 
          Regex.run(~r/Phoenix v(\d+\.\d+).*/, response) 
          |> List.last() 
          |> String.to_float()
      end
    end
  end


  @doc """
  Build options for phoenix.new or phx.new(if installed) task.
  """
  @spec get_ingredient_opts([]) :: [Option.t]
  def get_ingredient_opts([path, phx_version]) do
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


end
