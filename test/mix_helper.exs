###
# Copied from 
# https://github.com/phoenixframework/phoenix/blob/master/installer/test/mix_helper.exs
###

# Get Mix output sent to the current
# process to avoid polluting tests.
Mix.shell(Mix.Shell.Process)

# Mock live reloading for testing the generated application.
defmodule Phoenix.LiveReloader do
  def init(opts), do: opts
  def call(conn, _), do: conn
end

defmodule MixHelper do
  import ExUnit.Assertions
  import ExUnit.CaptureIO

  def tmp_path do
    Path.expand("../tmp", __DIR__)
  end

  def in_tmp(which, function) do
    path = Path.join(tmp_path(), to_string(which))
    File.rm_rf! path
    File.mkdir_p! path
    File.cd! path, function
  end

  def in_tmp_project(which, function) do
    conf_before = Application.get_env(:phoenix_composer, :generators) || []
    path = Path.join(tmp_path(), to_string(which))
    File.rm_rf! path
    File.mkdir_p! path
    File.cd! path
    File.touch!("mix.exs")
    function.()
    Application.put_env(:phoenix_composer, :generators, conf_before)
  end

  def in_tmp_umbrella_project(which, function) do
    conf_before = Application.get_env(:phoenix_composer, :generators) || []
    path = Path.join(tmp_path(), to_string(which))
    apps_path = Path.join(path, "apps")
    File.rm_rf! path
    File.mkdir_p! path
    File.mkdir_p! apps_path
    File.cd! path
    File.touch!("mix.exs")
    File.cd! apps_path
    function.()
    Application.put_env(:phoenix_composer, :generators, conf_before)
  end

  def in_project(app, path, fun) do
    %{name: name, file: file} = Mix.Project.pop()

    try do
      capture_io(:stderr, fn ->
        Mix.Project.in_project(app, path, [], fun)
      end)
    after
      Mix.Project.push(name, file)
    end
  end

  def assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end

  def refute_file(file) do
    refute File.regular?(file), "Expected #{file} to not exist, but it does"
  end

  def assert_file(file, match) do
    cond do
      is_list(match) ->
        assert_file file, &(Enum.each(match, fn(m) -> assert &1 =~ m end))
      is_binary(match) or Regex.regex?(match) ->
        assert_file file, &(assert &1 =~ match)
      is_function(match, 1) ->
        assert_file(file)
        match.(File.read!(file))
      true -> raise inspect({file, match})
    end
  end

  def with_generator_env(new_env, fun) do
    Application.put_env(:phoenix_composer, :generators, new_env)
    try do
      fun.()
    after
      Application.delete_env(:phoenix_composer, :generators)
    end
  end

  def umbrella_mixfile_contents do
    """
    defmodule Umbrella.Mixfile do
      use Mix.Project

      def project do
        [
          apps_path: "apps",
          deps: deps()
        ]
      end

      defp deps do
        []
      end
    end
    """
  end

  def mixfile_contents do
    """
    defmodule Single.Mixfile do
      use Mix.Project

      def project do
        [
          app: :test,
          version: "0.0.1",
          elixir: "~> 1.4",
          elixirc_paths: elixirc_paths(Mix.env),
          compilers: [:phoenix, :gettext] ++ Mix.compilers,
          start_permanent: Mix.env == :prod,
          aliases: aliases(),
          deps: deps()
        ]
      end

      def application do
        [
          mod: {Test.Application, []},
          extra_applications: [:logger, :runtime_tools]
        ]
      end

      defp elixirc_paths(:test), do: ["lib", "test/support"]
      defp elixirc_paths(_),     do: ["lib"]

      defp deps do
        [
          {:phoenix, "~> 1.3.0"},
          {:phoenix_pubsub, "~> 1.0"},
          {:phoenix_ecto, "~> 3.2"},
          {:postgrex, ">= 0.0.0"},
          {:phoenix_html, "~> 2.10"},
          {:phoenix_live_reload, "~> 1.0", only: :dev},
          {:gettext, "~> 0.11"},
          {:cowboy, "~> 1.0"}
        ]
      end

      defp aliases do
        [
          "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
          "ecto.reset": ["ecto.drop", "ecto.setup"],
          "test": ["ecto.create --quiet", "ecto.migrate", "test"]
        ]
      end
    end
    """ 
  end

  def flush do
    receive do
      _ -> flush()
    after 0 -> :ok
    end
  end

  def get_tmp_folder() do
    "test_folder_#{:rand.uniform(1000)}"
  end
end
