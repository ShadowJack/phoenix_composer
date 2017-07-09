defmodule Ingredients.IngredientTest do
  use ExUnit.Case, async: true

  alias PhoenixComposer.Ingredients.Ingredient
  alias PhoenixComposer.Option


  @string_opt %Option{name: :string_option, description: "Prompt", default: "default"}
  @bool_opt %Option{name: :bool_option, description: "Yes?", default: true}


  test "selects prompt for options with string defaults" do
    send self(), {:mix_shell_input, :prompt, ""}

    responses = Ingredient.ask_user(@string_opt, [])

    assert_receive {:mix_shell, :prompt, ["Prompt"]}
    assert [{:string_option, "default"}] == responses
  end

  test "selects yes? for options with bool defaults" do
    send self(), {:mix_shell_input, :yes?, false}

    responses = Ingredient.ask_user(@bool_opt, [])

    assert_receive {:mix_shell, :yes?, ["Yes?"]}
    assert [{:bool_option, false}] == responses
  end

  test "doesn't prompt for an option if deps requirements are not fulfilled" do
    # create an option that depends on another boolean opt
    option = %Option{@string_opt | deps: [bool_option: true]}
    send self(), {:mix_shell_input, :yes?, false}
    responses = Ingredient.ask_user(@bool_opt, [])

    # As dependence is not fulfilled our option is not prompted
    updated_responses = Ingredient.ask_user(option, responses)

    refute_receive {:mix_shell, :prompt, [_]}
    assert updated_responses == responses
  end
end
