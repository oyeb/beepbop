defmodule BeepBop.State do
  @moduledoc false

  alias Ecto.Multi

  defstruct ~w(context multi struct valid?)a

  def new(struct) when is_map(struct) do
    %__MODULE__{
      struct: struct,
      context: %{},
      multi: Multi.new(),
      valid?: true
    }
  end

  def new(struct, context, multi \\ Multi.new()) when is_map(struct) and is_map(context) do
    %__MODULE__{
      struct: struct,
      context: context,
      multi: multi,
      valid?: true
    }
  end
end
