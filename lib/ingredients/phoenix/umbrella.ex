defmodule PhoenixComposer.Ingredients.Phoenix.Umbrella do
  
  @doc """
  Add paths of important subfolders of an umbrella project
  and other bindings to options list.
  """
  def add_bindings(phx_verion, base_path, opts) do
    opts
    |> Enum.into(%{base_path: base_path, phx_verion: phx_verion})
    |> put_app()
    |> put_web()
    |> put_root_app()
    |> Enum.into([])
  end

  defp put_app(%{base_path: base_path} = opts) do
    project_path = Path.expand(base_path <> "_umbrella")
    app_path = Path.join(project_path, "apps/#{base_path}")

    %{opts |
      app_path: app_path,
      project_path: project_path}
  end

  defp put_web(%{base_path: base_path, module: module, project_path: proj_path} = opts) do
    web_app = :"#{base_path}_web"
    web_namespace = Module.concat(["#{module}Web"])

    %{opts |
      web_app: web_app,
      lib_web_name: web_app,
      web_namespace: web_namespace,
      web_path: Path.join(proj_path, "apps/#{web_app}/")}
  end

  defp put_root_app(%{app: app, module: mod} = opts) do
    %{opts |
      root_app: :"#{app}_umbrella",
      root_mod: Module.concat(mod, "Umbrella")}
  end
end
