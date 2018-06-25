defmodule BeepBop.Example.CardPayment do
  @moduledoc """
  Sample schema for the state machine.
  """
  use Ecto.Schema

  schema("card_payment") do
    field(:status, :string, default: "pending")
  end
end
