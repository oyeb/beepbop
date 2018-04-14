defmodule BeepBop.Utils do
  @moduledoc false

  def extract_schema_name({:__aliases__, _, module_as_list}) do
    module_as_list
    |> List.last()
    |> Atom.to_string()
    |> Macro.underscore()
    |> String.to_atom()
  end

  def are_unique?([]), do: true

  def are_unique?(items) do
    Enum.reduce_while(items, %MapSet{}, fn item, acc ->
      if MapSet.member?(acc, item) do
        {:halt, false}
      else
        {:cont, MapSet.put(acc, item)}
      end
    end)
  end
end
