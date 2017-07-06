Code.require_file "mix_helper.exs", __DIR__

Mix.shell(Mix.Shell.Process)

defmodule PhxNewTest do
  use ExUnit.Case, async: true

  import MixHelper
  import ExUnit.CaptureIO

  alias Mix.Tasks.Phx.Compose

  @test_app "test"

  test "error is returned if phoenix is not installed" do
    Compose.get_phx_version("phx.fail")

    assert_received {:mix_shell, :error, ["Phoenix framework is not installed" <> _]}
  end

  test "doesn't ask for --umbrella option for Phoenix ~> 1.2.0" do
    in_tmp("test_umbrella_version", fn -> 
      answer_questions()
      version = 1.2

      Compose.generate_new_project(@test_app, version, []) 

      refute_receive {:mix_shell, :prompt, ["Do you want to generate an umbrella project" <> _]}

      flush()
    end)
  end

  test "asks for --umbrella option for Phoenix ~> 1.3.0" do
    in_tmp("test_umbrella_version", fn -> 
      answer_questions()
      version = 1.3

      Compose.generate_new_project(@test_app, version, []) 

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
