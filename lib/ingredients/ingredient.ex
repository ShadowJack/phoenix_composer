defmodule PhoenixComposer.Ingredients.Ingredient do
  @moduledoc """
  Module that defines a behaviour for an ingredient.

  Ingredient describes one entity that can be installed automatically.

  For example:
  * Template language - phoenix_html, phoenix_slime, phoenix_haml
  * CSS-preprocessor - SASS, SCSS, LESS, PostCSS
  * DAL-stuff - ecto(with DB adapters), eredis, amnesia
  * Authentication - guardian, coherence, oauth2, doorman
  * Authorization - canary, openmaize, canada
  ...
  """

  alias PhoenixComposer.Option

  # Struct with results of an ingredient
  defstruct errors: [], opts: [], args: [], influences: []

  @type answer :: String.t | boolean
  @type t :: %__MODULE__{errors: [], opts: Keyword.t, args: [], influences: [{atom, answer}]}

  @doc """
  Should return a description of the recipe:
  a list of options chosen by user,
  errors occured, args for the commands passed from the outside
  influences that are influencing something??? :)
  """
  @callback get_description(args :: [String.t], opts :: Keyword.t) :: __MODULE__.t

  @doc """
  Execute all required shell commands with options and arguments 
  passed from `get_description` and from other ingredients in the same recipe
  """
  @callback cmds(description :: __MODULE__.t) :: none

  @doc """
  Add a new dependency to mix.exs file
  """
  @callback deps(version :: String.t) :: none

  @doc """
  Add a new entry to config file
  """
  @callback config() :: none

  @doc """
  Adds new files from templates specified in the module implementing Ingredient
  passing `opts` to the eex templates
  """
  @callback add_files(opts :: Keyword.t) :: none

  @doc """
  Print some messages to the console
  """
  @callback todo() :: none


  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      alias PhoenixComposer.Option

      import unquote(__MODULE__)
      alias unquote(__MODULE__)

      @doc """
      Execute entire ingredient and returns 
      opts that were gathered in ingredient
      """
      def exec_ingredient(args \\ [], opts \\ []) do
        description = get_description(args, opts)

        # Execute all steps of ingredient
        cmds(description)
        # Each ingredient decides what to do with opts, 
        # but by default convention :deps_version option should be supported
        deps(description.opts)
        config()
        add_files(description.opts)
        todo()

        description.opts
      end

      def cmds(_), do: :ok

      def deps(_), do: :ok

      def config(), do: :ok

      def add_files(_), do: :ok

      def todo(), do: :ok

      defoverridable [cmds: 1, deps: 1, config: 0, add_files: 1, todo: 0]
    end
  end



  ## Helpers
  #

  @doc """
  Asks user a new question in console depending on 
  the default value of the answer.
  
  If default answer is string then question is prompted.
  If default answer is bool then [Yn] answer is expected.
  """
  @spec ask_user(Option.t, [{atom, answer}]) :: [{atom, answer}]
  def ask_user(option, prev_answers) do
    if should_ask?(prev_answers, option.name, option.deps) do
      do_ask_user(option, prev_answers)
    else
      prev_answers
    end
  end

  # Should ask the new question only if all its dependencies are positive
  # and answer hasn't been passed from outside
  @spec should_ask?([{atom, answer}], atom, [{atom, boolean}]) :: boolean
  defp should_ask?(prev_answers, opt_name, deps) do
    if (Keyword.has_key?(prev_answers, opt_name)) do
      false
    else
      Enum.all?(prev_answers, fn {name, value} -> 
        case Enum.find(deps, fn {dep_name, _} -> dep_name == name end) do
          {_, dep_value} -> dep_value == value
          nil -> true
        end
      end)
    end
  end
  @spec do_ask_user(%Option{default: String.t}, [{atom, answer}]) :: [{atom, answer}]
  defp do_ask_user(%Option{default: default} = option, answers) when is_binary(default) do
    response = Mix.shell.prompt(option.description) |> String.trim()
    case response do
      ""       -> [{option.name, default} | answers]
      value -> [{option.name, value} | answers]
    end
  end
  @spec do_ask_user(%Option{default: boolean}, [{atom, answer}]) :: [{atom, answer}]
  defp do_ask_user(%Option{default: default} = option, answers) when is_boolean(default) do
    value = Mix.shell.yes?(option.description)
    [{option.name, value} | answers]
  end

  @doc """
  Adds a new line to dependencies with
  passed dependency description
  """
  @spec add_deps({atom, String.t}, []) :: none
  def add_deps(dep, opts) do
    mix_path = Keyword.get(opts, :base_path) |> Path.join("mix.exs")

    {:ok, content} = File.read(mix_path)
    content = String.replace(content, ~r/deps do(.*)\]/s, "deps do\\g{1},\n#{inspect(dep)}]")
    File.rm(mix_path)
    File.write(mix_path, content)
  end
end
