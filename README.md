# BeepBop

[![Build Status](https://travis-ci.org/oyeb/beepbop.svg?branch=develop)](https://travis-ci.org/oyeb/beepbop)
[![codecov](https://codecov.io/gh/oyeb/beepbop/branch/develop/graph/badge.svg)](https://codecov.io/gh/oyeb/beepbop)

## TODO

* [x] Check if the module is actually a Schema, and that it has the given filed in the struct.
* [ ] Compile time warnings about unused states.
* [x] Implement `%{from: %{not: []}}`.
* [x] Implement `%{from: :any}`.
* [x] Implement some custom compile time warnings/checks like ecto
* [x] Ensure that event names are unique!
* [ ] Move event function generation to `__before_compile__`
* [ ] Write tests to cover compile time errors/warnings with `Code.eval_quoted`

## Installation

The package can be installed in your project by adding `beepbop` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:beepbop, "~> 0.1.0", github: "oyeb/beepbop"}
  ]
end
```
