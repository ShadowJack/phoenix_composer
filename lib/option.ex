defmodule PhoenixComposer.Option do
  @moduledoc """
  This module declares `Option` struct.
  
  Each option must have a `name` and `default` value.
  Optional fields are `description` and `deps`(for boolean options only).
  `description` will be prompted to user. 
  `deps` is a keyword list `option_name: required_value`.
  This option will be prompted only if user satisfied all requirements in `deps`.
  
  """
  @enforce_keys [:name, :default]
  defstruct name: nil, description: "", default: nil, deps: []

  @type t :: %__MODULE__{name: atom, description: String.t, default: String.t | boolean, deps: [{atom, boolean}]}
end
