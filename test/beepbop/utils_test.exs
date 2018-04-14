defmodule BeepBop.UtilsTest do
  use ExUnit.Case, async: true

  alias BeepBop.Utils

  test "are_unique?" do
    unique = [1, 2, 3]
    duplicates = [1, 2, 1]
    assert Utils.are_unique?(unique)
    refute Utils.are_unique?(duplicates)
  end
end
