defmodule PhoenixComposer.Recipes.PostgresHamlSassGuardianExmachinaRecipe do
  @moduledoc """
  An example recipe.
  """

  use PhoenixComposer.Recipes.Recipe

  alias PhoenixComposer.Ingredients.Phoenix 
  #alias PhoenixComposer.Ingredients.{Haml, Brunch}

  #recipe do
    #ingredient Phoenix, opts: [database: "postgres", no_ecto: false, no_html: true] do
  # 
  #       # Add phoenix_haml
  #       # TODO: move everything to ingredient, leave only options
  #       ingredient Haml do
  #         # Add {:phoenix_haml, "~> 0.2"} to deps into mix.exs
  #         deps "~> 0.2" 
  #         # Add configuration to config.ex file
  #         config
  #         # Execute bash commands
  #         cmds
  #         # Print todo message from the ingredient
  #         todo
  #       end
  # 
  #       # Add SASS support via brunch
  #       npm_install_dev %{"sass-brunch" => "2.10.4"}
  # 
  #       ingredient Guardian do
  #         deps "~> 1.0-beta"
  #         
  #         #TODO: move to ingredient
  #         add_file "lib/guardian.ex", "path/to/template", :dict_of_opts_passed_from_parent
  # 
  #         config
  #       end
  #end


#  end
end
