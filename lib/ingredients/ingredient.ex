defmodule PhoenixComposer.Ingredients.Ingredient do
  @moduledoc """
  Module that defines a behaviour for an ingredient
  """

  alias PhoenixComposer.Option

  # Struct with results of an ingredient
  defstruct errors: [], opts: [], args: [], influences: []

  @type answer :: String.t | boolean
  @type t :: %__MODULE__{errors: [], opts: [{atom, any}], args: [], influences: [{atom, answer}]}

  @doc """
  Returns a description of the recipe:
  a list of options chosen by user,
  errors occured, args for the commands passed from the outside
  influences that are influencing something??? :)
  """
  @callback get_description(args :: [String.t], opts :: [{atom, any}]) :: __MODULE__.t

  @doc """
  Executes shell commands with options and arguments passed
  """
  @callback exec_cmds(__MODULE__.t) :: none


  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      alias PhoenixComposer.Option

      import unquote(__MODULE__)
      alias unquote(__MODULE__)
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

end
