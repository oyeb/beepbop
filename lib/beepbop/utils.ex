defmodule BeepBop.Utils do
  @moduledoc false

  def extract_schema_name({:__aliases__, _, module_as_list}) do
    module_as_list
    |> List.last()
    |> Atom.to_string()
    |> Macro.underscore()
    |> String.to_atom()
  end
end
