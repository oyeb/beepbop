defmodule BeepBop.UtilsTest do
  use ExUnit.Case, async: true

  alias BeepBop.Utils

  @msg_missing_repo """
  Please configure an Ecto.Repo by passing an Ecto.Repo like so:
      use BeepBop, ecto_repo: YourProject.Repo
  """

  @msg_from_atom_list "bad 'from'/'not_from': should be a list of atoms, got: "
  @msg_from_empty "bad 'from': cannot be empty!"
  @msg_not_from_empty @msg_from_empty <> " Did you remove all using `:not_from`?"
  @msg_to_atom "bad 'to': expected atom, got: "

  @msg_bad_states "All states must be atoms, got: "
  @msg_events_unique "Event names must be unique."
  @msg_atleast_one_state "A State Machine must have atleast one state!"
  @msg_bad_transition_format "bad format of `options` in `event/3`, please refer the docs."

  @states ~w[foo bar baz]a

  @bad_transitions %{
    a: %{from: [:bar], to: :bar},
    b: %{from: @states, to: :void},
    c: %{from: [], to: :baz},
    d: %{from: [:void, :foo], to: :baz},
    e: %{from: [:void], to: :void}
  }

  @states_error ~s{    event 'e': bad 'from': [:void], bad 'to': :void
    event 'd': bad 'from': [:void]
    event 'c': #{@msg_not_from_empty}
    event 'b': bad 'to': :void}

  @good_transitions %{
    a: %{from: [:bar], to: :bar},
    b: %{from: @states, to: :baz}
  }

  @wrong_transitions %{foo: :bar}

  test "extract_schema_name/1" do
    alias BeepBop.Example.OrderMachine, as: FooBar
    assert Utils.extract_schema_name(quote(do: FooBar)) == :order_machine
    assert Utils.extract_schema_name(quote(do: Foo)) == :foo
    assert Utils.extract_schema_name(quote(do: BeepBop.Example.CardPayment)) == :card_payment
  end

  test "assert_repo!/1" do
    refute Utils.assert_repo!(ecto_repo: FooBar)
    assert_raise(RuntimeError, @msg_missing_repo, fn -> Utils.assert_repo!([]) end)
  end

  test "assert_num_states!/1" do
    assert_raise(RuntimeError, @msg_atleast_one_state, fn ->
      Utils.assert_num_states!([])
    end)

    refute Utils.assert_num_states!([:a])
  end

  test "assert_states!/1" do
    assert_raise(RuntimeError, @msg_bad_states <> "[1]", fn ->
      Utils.assert_states!([1])
    end)

    refute Utils.assert_states!([:a])
  end

  test "assert_unique_events!/1" do
    unique = [1, 2, 3]
    duplicates = [1, 2, 1]

    assert_raise(RuntimeError, @msg_events_unique, fn ->
      Utils.assert_unique_events!(duplicates)
    end)

    refute Utils.assert_unique_events!(unique)
  end

  test "assert_transition_opts!/1" do
    refute Utils.assert_transition_opts!(%{from: @states, to: :foo})
    refute Utils.assert_transition_opts!(%{from: :any, to: :foo})
    refute Utils.assert_transition_opts!(%{from: %{not_from: []}, to: :foo})
    refute Utils.assert_transition_opts!(%{from: %{not_from: @states}, to: :foo})

    assert_raise(RuntimeError, @msg_bad_transition_format, fn ->
      Utils.assert_transition_opts!(@wrong_transitions)
    end)

    assert_raise(RuntimeError, @msg_from_empty, fn ->
      Utils.assert_transition_opts!(%{from: [], to: :foo})
    end)

    assert_raise(RuntimeError, @msg_from_atom_list <> "[1, 2]", fn ->
      Utils.assert_transition_opts!(%{from: [1, 2], to: :foo})
    end)

    assert_raise(RuntimeError, @msg_from_atom_list <> "[1, 2]", fn ->
      Utils.assert_transition_opts!(%{from: %{not_from: [1, 2]}, to: :foo})
    end)

    assert_raise(RuntimeError, @msg_to_atom <> "[:foo]", fn ->
      Utils.assert_transition_opts!(%{from: @states, to: [:foo]})
    end)
  end

  test "assert_transitions!/2" do
    refute Utils.assert_transitions!(@states, @good_transitions)

    assert_raise(RuntimeError, @states_error, fn ->
      Utils.assert_transitions!(@states, @bad_transitions)
    end)
  end
end
