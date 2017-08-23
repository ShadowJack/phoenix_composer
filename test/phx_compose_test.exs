Mix.shell(Mix.Shell.Process)

defmodule PhxComposeTest do
  use ExUnit.Case, async: true


  alias Mix.Tasks.Phx.Compose

  test "current version is printed" do
    Compose.run(["-v"])
    assert_received {:mix_shell, :info, ["PhoenixComposer v" <> _]}
  end
end
