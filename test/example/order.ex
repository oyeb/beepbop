defmodule BeepBop.Example.Order do
  use Ecto.Schema

  schema("order") do
    field(:state, :string)
  end
end

defmodule BeepBop.Example.OrderMachine do
  use BeepBop, ecto_repo: BeepBop.TestRepo

  state_machine(
    BeepBop.Example.Order,
    :state,
    ~w[cart address payment shipping shipped cancelled]a
  ) do
  end
end

# defmodule BeepBop.Example.BadOrderMachine do
#   use BeepBop.Ecto
# end
