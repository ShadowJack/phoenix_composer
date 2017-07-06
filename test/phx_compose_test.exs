Code.require_file "mix_helper.exs", __DIR__

Mix.shell(Mix.Shell.Process)

defmodule PhxComposeTest do
  use ExUnit.Case, async: true

  import MixHelper
  import ExUnit.CaptureIO

  alias Mix.Tasks.Phx.Compose
  alias PhoenixComposer.Option

  @test_app "test"
  @string_opt %Option{name: :string_option, description: "Prompt", default: "default"}
  @bool_opt %Option{name: :bool_option, description: "Yes?", default: true}

  test "current version is printed" do
    Compose.run(["-v"])
    assert_received {:mix_shell, :info, ["PhoenixComposer v" <> _]}
  end

  test "checks if path to a new project is present" do
    assert capture_io(fn -> Compose.run([]) end) =~ "mix phx.compose PATH"
  end


  test "selects prompt for options with string defaults" do
    send self(), {:mix_shell_input, :prompt, ""}

    responses = Compose.ask_user(@string_opt, [])

    assert_receive {:mix_shell, :prompt, ["Prompt"]}
    assert [{:string_option, "default"}] == responses
  end

  test "selects yes? for options with bool defaults" do
    send self(), {:mix_shell_input, :yes?, false}

    responses = Compose.ask_user(@bool_opt, [])

    assert_receive {:mix_shell, :yes?, ["Yes?"]}
    assert [{:bool_option, false}] == responses
  end

  test "doesn't prompt for an option if deps requirements are not fulfilled" do
    # create an option that depends on another boolean opt
    option = %Option{@string_opt | deps: [bool_option: true]}
    send self(), {:mix_shell_input, :yes?, false}
    responses = Compose.ask_user(@bool_opt, [])

    # As dependence is not fulfilled our option is not prompted
    updated_responses = Compose.ask_user(option, responses)

    refute_receive {:mix_shell, :prompt, [_]}
    assert updated_responses == responses
  end
end
