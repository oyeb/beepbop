defmodule BeepBop.Example.Shipment do
  use Ecto.Schema

  schema("shipment") do
    field(:state, :string)
  end
end

defmodule BeepBop.Example.ShipmentMachine do
  use BeepBop, ecto_repo: BeepBop.TestRepo

  state_machine(
    BeepBop.Example.Shipment,
    :state,
    ~w[pending ready shipped cancelled returned]a
  ) do
    event(:add_item, %{from: [:pending, :ready]}, fn state ->
      state
    end)
  end
end
