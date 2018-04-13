defmodule BeepBop.Example.CardPayment do
  use Ecto.Schema

  schema("payment") do
    field(:status, :string)
  end
end

defmodule BeepBop.Example.CardPaymentMachine do
  use BeepBop, ecto_repo: BeepBop.TestRepo

  alias BeepBop.Example.CardPayment

  state_machine(CardPayment, :status) do
    states(~w[authorized captured refunded voided failed]a)
  end
end

defmodule BeepBopTest do
  use ExUnit.Case, async: true

  # alias BeepBop.Example.CardPayment
  alias BeepBop.Example.CardPaymentMachine, as: Machine

  test "metadata" do
    assert Machine.__beepbop__(:module) == BeepBop.Example.CardPayment
    assert Machine.__beepbop__(:column) == :status
    assert Machine.__beepbop__(:name) == :card_payment
    assert Machine.__beepbop__(:repo) == BeepBop.TestRepo
  end
end
