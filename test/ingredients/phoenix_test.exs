Code.require_file "../mix_helper.exs", __DIR__

Mix.shell(Mix.Shell.Process)

defmodule Ingredients.PhoenixTest do
  use ExUnit.Case, async: true

  import MixHelper
  import ExUnit.CaptureIO

  alias PhoenixComposer.Ingredients.Phoenix


  @test_app "test"


  test "checks if path to a new project is present" do
    assert capture_io(fn -> Phoenix.run([], []) end) =~ "mix phx.compose PATH"
  end


  test "error is returned if phoenix is not installed" do
    assert :not_installed == Phoenix.get_phx_version("phx.fail")
  end

  test "doesn't ask for --umbrella option for Phoenix ~> 1.2.0" do
    in_tmp("test_umbrella_version", fn -> 
      answer_questions()
      version = 1.2

      Phoenix.generate_new_project(@test_app, version, []) 

      refute_receive {:mix_shell, :prompt, ["Do you want to generate an umbrella project" <> _]}

      flush()
    end)
  end

  test "asks for --umbrella option for Phoenix ~> 1.3.0" do
    in_tmp("test_umbrella_version", fn -> 
      answer_questions()
      version = 1.3

      Phoenix.generate_new_project(@test_app, version, []) 

      assert_receive {:mix_shell, :yes?, ["Do you want to generate an umbrella project" <> _]}

      flush()
    end)
  end

  test "runs correct mix task depending on version of Phoenix" do
    
  end

  defp answer_questions() do
      1..3 |> Enum.each(fn(_x) -> send self(), {:mix_shell_input, :prompt, ""} end)
      1..5 |> Enum.each(fn(_x) -> send self(), {:mix_shell_input, :yes?, true} end)
  end
end

