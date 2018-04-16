defmodule BeepBop.Context do
  @moduledoc false

  alias Ecto.Multi

  defstruct ~w(struct state multi valid?)a

  def new(struct) when is_map(struct) do
    %__MODULE__{
      struct: struct,
      state: %{},
      multi: Multi.new(),
      valid?: true
    }
  end

  def new(struct, state, multi \\ Multi.new()) when is_map(struct) and is_map(state) do
    %__MODULE__{
      struct: struct,
      state: state,
      multi: multi,
      valid?: true
    }
  end
end
