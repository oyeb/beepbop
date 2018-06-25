defmodule BeepBop.Example.CardPaymentMachine do
  @moduledoc """
  The state machine module defines a `persist/2`, and we can check if BeepBop
  "uses" it or not with the `__persistor_check__/0`

  It seems that the relative ordering between `state_machine` macro and
  `persist/2` is crucial.

  ## Defined events
  * `:authorize`
  """
  use BeepBop, ecto_repo: BeepBop.TestRepo

  alias BeepBop.Example.CardPayment

  def persist(_, _), do: :ok

  state_machine(CardPayment, :status, ~w[pending authorized captured refunded voided failed]a) do
    event(:authorize, %{from: [:pending], to: :authorized}, fn context ->
      context
    end)
  end

  def __persistor_check__ do
    __beepbop_persist(:foo, :bar)
  end
end
