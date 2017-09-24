defmodule PhoenixComposer.Ingredients.Phoenix.Single do
  
  @doc """
  Add paths of important subfolders of a project
  and other bindings to options list.
  """
  def add_bindings(phx_verion, base_path, opts) do
    opts
    |> Enum.into(%{base_path: base_path, phx_verion: phx_verion})
    |> put_app()
    |> put_root_app()
    |> put_web_app()
    |> Enum.into([])
  end

  defp put_app(%{base_path: base_path} = opts) do
    %{opts | 
      app_path: base_path, 
      project_path: base_path}
  end

  defp put_root_app(%{app: app, module: mod} = opts) do
    %{opts |
      root_app: app,
      root_mod: mod}
  end

  defp put_web_app(%{app: app, phx_verion: phx_verion} = opts) when phx_verion >= 1.3 do
    %{opts |
      web_app: app,
      lib_web_name: "#{app}_web",
      web_namespace: Module.concat(["#{opts.root_mod}Web"]),
      web_path: opts.project_path}
  end
  defp put_web_app(%{app: app} = opts) do
    %{opts |
      web_app: app,
      lib_web_name: "#{app}_web",
      web_namespace: Module.concat(["#{opts.root_mod}Web"]),
      web_path: Path.expand("web", opts.project_path)}
  end
end
