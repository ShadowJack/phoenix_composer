Code.require_file "../mix_helper.exs", __DIR__

Mix.shell(Mix.Shell.Process)

defmodule Ingredients.PhoenixTest do
  use ExUnit.Case, async: true

  import MixHelper
  import ExUnit.CaptureIO

  alias PhoenixComposer.Ingredients.Phoenix
  alias PhoenixComposer.Option


  @test_app "test"


  test "checks if path to a new project is present" do
    assert capture_io(fn -> Phoenix.run([], []) end) =~ "mix phx.compose PATH"
  end


  test "error is returned if phoenix is not installed" do
    assert :not_installed == Phoenix.get_phx_version("phx.fail")
  end

  test "doesn't ask for --umbrella option for Phoenix ~> 1.2.0" do
    version = 1.2

    opts = Phoenix.get_ingredient_opts([@test_app, version]) 

    refute Enum.any?(opts, fn %Option{name: name} -> name == :umbrella end)
  end

  test "asks for --umbrella option for Phoenix ~> 1.3.0" do
    version = 1.3

    opts = Phoenix.get_ingredient_opts([@test_app, version]) 

    assert Enum.any?(opts, fn %Option{name: name} -> name == :umbrella end)
  end

  test "runs mix task that generates Phoenix project" do
    in_tmp(get_tmp_folder(), fn -> 
      answer_questions()
      
      Phoenix.run([@test_app], [])

      assert_file("#{@test_app}/mix.exs", "phoenix")
    end)
  end

  test "mix phx.new or phoenix.new task respects answers of the user" do
    in_tmp(get_tmp_folder(), fn -> 
      answer_questions(false)

      Phoenix.run([@test_app], [])

      # No files for ecto
      assert_file("#{@test_app}/mix.exs")
      refute_file("#{@test_app}/lib/#{@test_app}/repo.ex")
    end)
  end

  defp answer_questions(with_ecto \\ true) do
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :prompt, "\n"}
    send self(), {:mix_shell_input, :prompt, "\n"}
    send self(), {:mix_shell_input, :yes?, with_ecto}
    send self(), {:mix_shell_input, :prompt, "\n"}
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, true}
    send self(), {:mix_shell_input, :yes?, true}
    #send self(), {:mix_shell_input, :yes?, false}
    # 1..3 |> Enum.each(fn(_x) -> send self(), {:mix_shell_input, :prompt, ""} end)
    # 1..6 |> Enum.each(fn(_x) -> send self(), {:mix_shell_input, :yes?, false} end)
  end

  defp get_tmp_folder() do
    "test_folder_#{:rand.uniform(1000)}"
  end
end

