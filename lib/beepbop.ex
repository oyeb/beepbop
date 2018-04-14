defmodule BeepBop do
  @moduledoc """
  Manages the state machine of an `Ecto.Schema`.
  """

  alias Ecto.Multi
  alias BeepBop.Utils

  @doc """
  Configures `BeepBop` to work with your `Ecto.Repo`.

  Expected keyword arguments:
  * `:ecto_repo` -- Since BeepBop does the routine persisting of "state", it
    needs to know which `Ecto.Repo` to use.
  """
  defmacro __using__(opts) do
    unless Keyword.has_key?(opts, :ecto_repo) do
      raise(~s{Please configure an Ecto.Repo by passing an Ecto.Repo
    like so:
    use BeepBop, ecto_repo: YourProject.Repo
})
    end

    quote location: :keep do
      import BeepBop
      alias Ecto.Multi

      def __beepbop__(:repo), do: Keyword.fetch!(unquote(opts), :ecto_repo)

      Module.register_attribute(__MODULE__, :from_states, accumulate: true)
      Module.register_attribute(__MODULE__, :to_states, accumulate: true)
      Module.register_attribute(__MODULE__, :event_names, accumulate: true)

      @before_compile BeepBop
    end
  end

  defmacro state_machine(schema, column, states, do: block) do
    # TODO: should validate that such a module exists and it does have the
    # specified column
    name = Utils.extract_schema_name(schema)

    quote location: :keep,
          bind_quoted: [
            name: name,
            schema: schema,
            column: column,
            states: states,
            block: block
          ] do
      Module.eval_quoted(__MODULE__, [
        metadata(name, schema, column, states),
        context_validator(schema)
      ])

      @doc """
      Returns the list of defined states in this machine.
      """
      @spec states :: [atom]
      def states do
        @beepbop_states
      end

      @doc """
      Checks if given `state` is defined in this machine.
      """
      @spec state_defined?(atom) :: boolean
      def state_defined?(state) do
        Enum.member?(@beepbop_states, state)
      end

      defp _beepbop_try_persist(%BeepBop.State{struct: struct, multi: multi}, to_state) do
        Multi.run(multi, :persist, fn changes ->
          updated_struct = Map.get(changes, @beepbop_name) || struct
          to = Atom.to_string(to_state)
          _beepbop_persist(updated_struct, to)
        end)
      end

      block
    end
  end

  defmacro event(event, options, callback) do
    quote location: :keep do
      {event_from_states, to} =
        case unquote(options) do
          %{not: not_from, to: to} ->
            {Enum.reject(@beepbop_states, fn x -> x in not_from end), to}

          %{from: :any, to: to} ->
            {@beepbop_states, to}

          %{from: from, to: to} ->
            {from, to}
        end

      @from_states {unquote(event), event_from_states}
      @to_states {unquote(event), to}
      @event_names unquote(event)

      @doc """
      Runs the defined callback for this event.

      This function was generated by the `BeepBop.event/3` macro.
      """
      @spec unquote(event)(map, keyword) :: {:ok, map | struct} | {:error, term}
      def unquote(event)(context, opts \\ []) do
        persist? = Keyword.get(opts, :persist, true)
        repo_opts = Keyword.get(opts, :repo, [])

        if can_transition?(context, unquote(event)) do
          result =
            context
            |> case do
              %BeepBop.State{} = context -> context
              %{} = context -> BeepBop.State.new(context)
            end
            |> unquote(callback).()

          %{to: to_state} = unquote(options)
          multi = _beepbop_try_persist(context, to_state)

          if result.valid? and persist? do
            repo = __beepbop__(:repo)
            repo.transaction(multi, repo_opts)
          else
            {:error, result}
          end
        else
          {:error, "bad context"}
        end
      end
    end
  end

  def metadata(name, schema, column, states) do
    quote location: :keep,
          bind_quoted: [
            name: name,
            module: schema,
            column: column,
            states: states
          ] do
      @beepbop_name name
      @beepbop_module module
      @beepbop_column column
      @beepbop_states states

      def __beepbop__(:name), do: @beepbop_name
      def __beepbop__(:module), do: @beepbop_module
      def __beepbop__(:column), do: @beepbop_column
      def __beepbop__(:states), do: @beepbop_states
    end
  end

  def context_validator(schema) do
    quote location: :keep do
      @doc """
      Validates the `context` struct.

      Returns `true` if `context` contains a struct of type `#{@beepbop_module}`
      under the `:struct` key.
      """
      @spec valid_context?(BeepBop.State.t()) :: boolean
      def valid_context?(context)

      def valid_context?(%BeepBop.State{
            struct: %unquote(schema){},
            valid?: true,
            context: c,
            multi: %Multi{}
          })
          when is_map(c),
          do: true

      def valid_context?(_), do: false
    end
  end

  def persistor(module) do
    if Module.defines?(module, {:persist, 2}, :def) do
      quote location: :keep do
        defp _beepbop_persist(struct, to_state) do
          __MODULE__.persist(struct, to_state)
        end
      end
    else
      quote location: :keep do
        defp _beepbop_persist(struct, to_state) do
          {:ok, Map.put(struct, @beepbop_column, to_state)}
        end
      end
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    events = Module.get_attribute(env.module, :event_names)

    unless Utils.are_unique?(events) do
      raise "Event names must be unique in {inspect(env.module)}"
    end

    quote location: :keep do
      Module.eval_quoted(__MODULE__, persistor(__MODULE__))

      def __beepbop__(:events), do: @event_names

      def __beepbop__(:transitions) do
        for event <- @event_names, into: %{} do
          {event,
           %{
             from: Keyword.fetch!(@from_states, event),
             to: Keyword.fetch!(@to_states, event)
           }}
        end
      end

      @doc """
      Validates the `context` struct and checks if the transition via `event` is
      valid.
      """
      @spec can_transition?(BeepBop.State.t(), atom) :: boolean
      def can_transition?(context, event) do
        if valid_context?(context) do
          state =
            context.struct
            |> Map.get(__beepbop__(:column))
            |> String.to_atom()

          from_states = Keyword.fetch!(@from_states, event)
          state in from_states
        else
          false
        end
      end
    end
  end
end
