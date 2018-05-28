defmodule BeepBop.ContextTest do
  use ExUnit.Case, async: true

  alias BeepBop.Context
  alias Ecto.Multi

  defstruct [:dummy]

  test "new/1" do
    assert %Context{
             struct: %__MODULE__{
               dummy: :beep
             },
             state: %{},
             multi: %Multi{},
             valid?: true
           } = Context.new(%__MODULE__{dummy: :beep})
  end

  test "new/3" do
    assert %Context{
             struct: %__MODULE__{
               dummy: :bop
             },
             state: %{best_library_ever: :beepbop},
             multi: %Multi{},
             valid?: false
           } =
             Context.new(
               %__MODULE__{dummy: :bop},
               state: %{best_library_ever: :beepbop},
               valid?: false
             )
  end
end
