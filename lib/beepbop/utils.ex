defmodule BeepBop.Utils do
  @moduledoc false

  @msg_missing_repo """
  Please configure an Ecto.Repo by passing an Ecto.Repo like so:
      use BeepBop, ecto_repo: YourProject.Repo
  """
  @msg_not_a_struct "does not define a struct"
  @msg_missing_column "doesn't have any column named:"
  @msg_not_loaded "could not be loaded"

  @msg_from_atom_list "bad 'from'/'not_from': should be a list of atoms, got: "
  @msg_from_empty "bad 'from': cannot be empty!"
  @msg_not_from_empty @msg_from_empty <> " Did you remove all using `:not_from`?"
  @msg_to_atom "bad 'to': expected atom, got: "

  @msg_bad_states "All states must be atoms, got: "
  @msg_events_unique "Event names must be unique."
  @msg_atleast_one_state "A State Machine must have atleast one state!"
  @msg_bad_transition_format "bad format of `options` in `event/3`, please refer the docs."

  def extract_schema_name(schema_module, env) do
    schema_module
    |> Macro.expand_once(env)
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.to_atom()
  end

  def assert_repo!(opts) do
    unless Keyword.has_key?(opts, :ecto_repo) do
      raise(@msg_missing_repo)
    end
  end

  def assert_schema!(schema, column) do
    if Code.ensure_compiled?(schema) do
      unless function_exported?(schema, :__schema__, 1) do
        raise("#{inspect(schema)} #{@msg_not_a_struct}")
      end

      unless column in schema.__schema__(:fields) do
        raise("#{inspect(schema)} #{@msg_missing_column} #{inspect(column)}")
      end
    else
      raise("#{inspect(schema)} #{@msg_not_loaded}")
    end
  end

  def assert_num_states!([]) do
    raise @msg_atleast_one_state
  end

  def assert_num_states!(_), do: nil

  def assert_states!(states) when is_list(states) do
    unless Enum.all?(states, fn x -> is_atom(x) end) do
      raise @msg_bad_states <> inspect(states)
    end
  end

  def assert_states!(states), do: raise(@msg_bad_states <> inspect(states))

  def assert_unique_events!(events) do
    unless are_unique?(events) do
      raise @msg_events_unique
    end
  end

  def assert_transition_opts!(%{from: from, to: to}) do
    f = validate_from(from)
    unless f == :ok, do: raise(f)

    t = validate_to(to)
    unless t == :ok, do: raise(t)
  end

  def assert_transition_opts!(%{from: from}) do
    assert_transition_opts!(%{from: from, to: nil})
  end

  def assert_transition_opts!(_) do
    raise @msg_bad_transition_format
  end

  defp validate_from([]), do: @msg_from_empty
  defp validate_from(:any), do: :ok
  defp validate_from(%{not: []}), do: :ok
  defp validate_from(%{not: not_from}), do: validate_from(not_from)

  defp validate_from(from) when is_list(from) do
    if Enum.all?(from, fn x -> is_atom(x) end),
      do: :ok,
      else: @msg_from_atom_list <> inspect(from)
  end

  defp validate_from(from), do: @msg_from_atom_list <> inspect(from)

  defp validate_to(to) when is_atom(to), do: :ok
  defp validate_to(to), do: @msg_to_atom <> inspect(to)

  def assert_transitions!(states, transitions) do
    transitions
    |> Enum.reduce([], fn {event, transition}, acc ->
      [validate_event(states, event, transition) | acc]
    end)
    |> Enum.reject(fn x -> x == nil end)
    |> case do
      [] -> nil
      invalids -> raise(Enum.join(invalids, "\n"))
    end
  end

  defp validate_event(states, event, %{from: from, to: to}) do
    f = validate_from_states(states, from)
    t = validate_to_state(states, to)

    if f || t do
      "    event '#{event}': #{f}#{if f && t, do: ", "}#{t}"
    end
  end

  defp validate_event(states, event, %{from: from}) do
    validate_event(states, event, %{from: from, to: nil})
  end

  defp validate_from_states(_, []), do: @msg_not_from_empty

  defp validate_from_states(states, from) when is_list(from) do
    case Enum.reject(from, &Enum.member?(states, &1)) do
      [] -> nil
      invalids -> "bad 'from': #{inspect(invalids)}"
    end
  end

  defp validate_to_state(states, to) when is_atom(to) do
    unless to in states or is_nil(to) do
      "bad 'to': #{inspect(to)}"
    end
  end

  defp validate_to_state(_, _), do: false

  defp are_unique?([]), do: true

  defp are_unique?(items) do
    Enum.reduce_while(items, %MapSet{}, fn item, acc ->
      if MapSet.member?(acc, item) do
        {:halt, false}
      else
        {:cont, MapSet.put(acc, item)}
      end
    end)
  end
end
