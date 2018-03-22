defmodule BeepBop.State do
  alias Ecto.Multi
  
  defstruct ~w(context multi)a

  def new do
    %__MODULE__{context: %{}, multi: Multi.new()}
  end
  
  def new(context, multi \\ Multi.new()) when is_map(context) do
    %__MODULE__{context: context, multi: multi}
  end
end
