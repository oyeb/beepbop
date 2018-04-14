defmodule BeepBopTest do
  defstruct [:dummy]

  use ExUnit.Case, async: true

  alias BeepBop.Example.CardPayment
  alias BeepBop.Example.CardPaymentMachine, as: Machine
  alias BeepBop.Example.CardPaymentMachine.WithoutPersist

  require IEx

  @states ~w[pending authorized captured refunded voided failed]a
  @events ~w[authorize]a

  test "metadata" do
    assert Machine.__beepbop__(:module) == BeepBop.Example.CardPayment
    assert Machine.__beepbop__(:column) == :status
    assert Machine.__beepbop__(:name) == :card_payment
    assert Machine.__beepbop__(:repo) == BeepBop.TestRepo
    assert @events = Machine.__beepbop__(:events)
    assert @states = Machine.__beepbop__(:states)

    assert %{
             authorize: %{from: [:pending], to: :authorized}
           } = Machine.__beepbop__(:transitions)
  end

  test "context validator" do
    context = BeepBop.State.new(%CardPayment{})
    bad_context = BeepBop.State.new(%BeepBopTest{})
    assert Machine.valid_context?(context)
    refute Machine.valid_context?(%{})
    refute Machine.valid_context?(%BeepBop.State{valid?: false, struct: %CardPayment{}})
    refute Machine.valid_context?(bad_context)
  end

  test "transition validator" do
    assert Machine.can_transition?(BeepBop.State.new(%CardPayment{}), :authorize)
    refute Machine.can_transition?(BeepBop.State.new(%CardPayment{status: "lol"}), :authorize)

    refute Machine.can_transition?(
             %BeepBop.State{struct: %CardPayment{}, valid?: false},
             :authorize
           )
  end

  test "persistor: module with persist/2" do
    assert :ok = Machine.__persistor_check__()
  end

  test "persistor: module without persist/2" do
    assert {:ok, %CardPayment{status: :bar}} = WithoutPersist.__persistor_check__()
  end
end
