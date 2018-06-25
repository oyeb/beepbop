defmodule BeepBop.Example.Order do
  @moduledoc """
  Sample schema for the state machine.
  """
  use Ecto.Schema

  schema("order") do
    field(:state, :string)
  end
end
