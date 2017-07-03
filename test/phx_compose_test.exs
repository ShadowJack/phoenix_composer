Code.require_file "mix_helper.exs", __DIR__

Mix.shell(Mix.Shell.Process)

defmodule PhxComposeTest do
  use ExUnit.Case, async: true

  import MixHelper
  import ExUnit.CaptureIO

  alias Mix.Tasks.Phx.Compose

  @test_app "test"

  test "current version is printed" do
    Compose.run(["-v"])
    assert_received {:mix_shell, :info, ["PhoenixComposer v" <> _]}
  end
end
