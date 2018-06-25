defmodule BeepBop.Example.OrderMachineTest do
  defstruct [:dummy]

  use ExUnit.Case, async: true

  alias BeepBop.Context
  alias BeepBop.Example.Order
  alias BeepBop.Example.OrderMachine, as: Machine

  @states ~w[cart address payment shipping shipped cancelled]a
  @events ~w[will_fail foobar]a

  test "metadata" do
    assert Machine.__beepbop__(:module) == BeepBop.Example.Order
    assert Machine.__beepbop__(:column) == :state
    assert Machine.__beepbop__(:name) == :order
    assert Machine.__beepbop__(:repo) == BeepBop.TestRepo
    assert @events = Machine.__beepbop__(:events)
    assert @states = Machine.__beepbop__(:states)

    assert %{
             foobar: %{from: [:cart], to: nil}
           } = Machine.__beepbop__(:transitions)
  end

  test "context validator" do
    assert Machine.valid_context?(Context.new(%Order{}))

    refute Machine.valid_context?(%{})
    refute Machine.valid_context?(Context.new(%Order{}, valid?: false))
    refute Machine.valid_context?(Context.new(%__MODULE__{}))
  end

  test "transition validator" do
    assert Machine.can_transition?(Context.new(%Order{state: "cart"}), :foobar)
    refute Machine.can_transition?(Context.new(%Order{state: "lol"}), :foobar)

    refute Machine.can_transition?(
             %Context{struct: %Order{}, valid?: false},
             :authorize
           )
  end

  describe "check transitions" do
    test "fails with bad order.state" do
      assert %Context{
               errors: {:error, "cannot transition, bad context"},
               valid?: false
             } =
               %Order{state: "pending"}
               |> Context.new()
               |> Machine.foobar()
    end

    test "foobar with correct context" do
      assert %Context{
               valid?: true
             } =
               %Order{state: "cart"}
               |> Context.new()
               |> Machine.foobar()
    end

    test "will_fail with correct context" do
      assert %Context{
               valid?: false,
               errors: {:error, :failure, :failed, %{}}
             } =
               %Order{state: "cart"}
               |> Context.new()
               |> Machine.will_fail()
    end
  end
end
