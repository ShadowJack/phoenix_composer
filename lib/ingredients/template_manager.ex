defmodule PhoenixComposer.Ingredients.TemplateManager do
  @moduledoc """
  Module that makes it possible to use eex or plain text templates in recipes. 
  The biggest part is taken from 
  https://github.com/phoenixframework/phoenix/blob/master/installer/lib/phx_new/generator.ex

  """

  defmacro __using__(_env) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :templates, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  # All templates should be inside 
  # `ingredients/#{ingredient_name}/templates/` folder
  defmacro __before_compile__(env) do
    dir = Path.dirname(__CALLER__.file)
    root = Path.expand("templates", dir)
    templates_ast = for {name, mappings} <- Module.get_attribute(env.module, :templates) do
      for {format, source, _, _} <- mappings, format != :keep do
        path = Path.join(root, source)
        quote do
          @external_resource unquote(path)
          def render(unquote(name), unquote(source)), do: unquote(File.read!(path))
        end
      end
    end

    quote do
      unquote(templates_ast)
      def template_files(name), do: Keyword.fetch!(@templates, name)
    end
  end

  @doc """
  Macro for describing a template.

  Each template is described by a `name` and any number of `mappings`.
  Mapping is a tuple of `{format, source, project_location, target_path}`.

  `format` describes how template will be processed
  * `:keep` - copy a folder with all files inside
  * `:text` - create a new file without binding substitutions
  * `:append` - append text to the end of the file
  * `:eex` - create a new file and fill with data from template while interpolating bindings

  `source` is a relative path to the template file/folder inside 
  `/ingredients/#{ingredient_name}/templates/` folder.

  `project_location` describes where the output should be placed
  * `:project` - template target is relative to project folder
  * `:app` - template target is relative to application folder.
  It's different from `:project` option in umbrella projects.
  * `:web` - template target is relative to the web foler

  `target_path` is a path to the destination, where result should be put.
  This path is relative to `project_location`.
  """
  defmacro template(name, mappings) do
    quote do
      @templates {unquote(name), unquote(mappings)}
    end
  end

  @doc """
  Copy data from template with `name` located in module `mod`
  to the destination while interpolating `bindings`
  """
  def copy_from(project_path, bindings, mod, name) when is_atom(name) do
    mapping = mod.template_files(name)
    for {format, source, project_location, target_path} <- mapping do
      target = join_path(bindings, project_location, target_path)

      case format do
        :keep ->
          File.mkdir_p!(target)
        :text ->
          Mix.Generator.create_file(target, mod.render(name, source))
        :append ->
          append_to(Path.dirname(target), Path.basename(target), mod.render(name, source))
        :eex  ->
          contents = EEx.eval_string(mod.render(name, source), bindings, file: source)
          Mix.Generator.create_file(target, contents)
      end
    end
  end

  # Build full path to the target while interpolating bindings
  defp join_path(bindings, location, path) when location in [:project, :app, :web] do
    bindings
    |> Map.fetch!(:"#{location}_path")
    |> Path.join(path)
    |> expand_path_with_bindings(bindings)
  end

  #TODO: is recompilation of the regex required?
  defp expand_path_with_bindings(path, bindings) do
    Regex.replace(~r/:[a-zA-Z0-9_]+/, path, fn ":" <> key, _ ->
        bindings |> Map.fetch!(:"#{key}") |> to_string()
    end)
  end

  defp append_to(path, file, contents) do
    file = Path.join(path, file)
    File.write!(file, File.read!(file) <> contents)
  end
end
