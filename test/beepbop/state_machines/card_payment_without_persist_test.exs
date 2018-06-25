defmodule BeepBop.Example.CardPaymentMachine.WithoutPersistTest do
  defstruct [:dummy]

  use ExUnit.Case, async: true

  alias BeepBop.Example.CardPayment
  alias BeepBop.Example.CardPaymentMachine.WithoutPersist, as: Machine

  @states ~w[pending cancelled]a
  @events ~w[cancel]a

  test "metadata" do
    assert Machine.__beepbop__(:module) == BeepBop.Example.CardPayment
    assert Machine.__beepbop__(:column) == :status
    assert Machine.__beepbop__(:name) == :card_payment
    assert Machine.__beepbop__(:repo) == BeepBop.TestRepo
    assert @events = Machine.__beepbop__(:events)
    assert @states = Machine.__beepbop__(:states)

    assert %{
             cancel: %{from: [:pending], to: :cancelled}
           } = Machine.__beepbop__(:transitions)
  end

  test "valid_context?" do
    assert Machine.valid_context?(BeepBop.Context.new(%CardPayment{}))

    refute Machine.valid_context?(%{})
    refute Machine.valid_context?(BeepBop.Context.new(%CardPayment{}, valid?: false))
    refute Machine.valid_context?(BeepBop.Context.new(%__MODULE__{}))
  end

  test "can_transition?" do
    assert Machine.can_transition?(BeepBop.Context.new(%CardPayment{status: "pending"}), :cancel)
    refute Machine.can_transition?(BeepBop.Context.new(%CardPayment{status: "lol"}), :cancel)

    refute Machine.can_transition?(
             %BeepBop.Context{struct: %CardPayment{}, valid?: false},
             :cancel
           )
  end

  test "persistor: module with persist/2" do
    assert {:ok, %CardPayment{status: :bar}} = Machine.__persistor_check__()
  end
end
