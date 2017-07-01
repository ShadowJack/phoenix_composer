Code.require_file "mix_helper.exs", __DIR__

Mix.shell(Mix.Shell.Process)

defmodule PhxComposeTest do
  use ExUnit.Case
  import MixHelper
  import ExUnit.CaptureIO

  @test_app "test"

  test "error is returned if phoenix is not installed" do
    Mix.Tasks.Phx.Compose.get_phx_version("phx.fail")
    assert_received {:mix_shell, :error, ["Phoenix framework is not installed" <> _]}
  end

  test "current version is printed" do
    Mix.Tasks.Phx.Compose.run(["-v"])
    assert_received {:mix_shell, :info, ["PhoenixComposer v" <> _]}
  end
end
