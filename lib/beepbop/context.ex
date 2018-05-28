defmodule BeepBop.Context do
  @moduledoc false

  alias Ecto.Multi

  defstruct ~w(struct state multi valid?)a

  @typedoc """
  The Context struct
  """
  @type t :: %__MODULE__{
          struct: struct,
          state: map,
          multi: Multi.t(),
          valid?: boolean
        }

  @spec new(struct, keyword) :: t
  def new(struct, opts \\ []) when is_map(struct) do
    %__MODULE__{
      struct: struct,
      state: Keyword.get(opts, :state, %{}),
      multi: Keyword.get(opts, :multi, Multi.new()),
      valid?: Keyword.get(opts, :valid?, true)
    }
  end
end
