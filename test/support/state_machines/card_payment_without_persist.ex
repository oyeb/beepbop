defmodule BeepBop.Example.CardPaymentMachine.WithoutPersist do
  @moduledoc """
  The state machine module lacks a `persist/2`

  ## Defined events
  * `:cancel`
  """
  use BeepBop, ecto_repo: BeepBop.TestRepo

  alias BeepBop.Example.CardPayment, as: CP

  state_machine(CP, :status, ~w[pending cancelled]a) do
    event(:cancel, %{from: %{not: [:cancelled]}, to: :cancelled}, fn context ->
      context
    end)
  end

  def __persistor_check__ do
    __beepbop_persist(%CP{}, :bar)
  end
end
