# BeepBop

## TODO

* [ ] Accept module name for `callback`. What if callback is not implemented in the module? Compile time warnings/error
* [ ] Remove dependency on `Multi`, by making `BeepBop.Ecto`
* [ ] Compile time warnings about undefined states/unused states.
* [x] Implement `%{from: %{not: []}}`.
* [ ] Assert non empty from_list, not_list.
* [x] Implement `%{from: :any}`.
* [ ] Implement some custom compile time warnings/checks like ecto
* [ ] Ensure that event names are unique!


* Validate with community
* Pure version?

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
