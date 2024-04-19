defmodule CounterStateTest do
  use PropCheck, default_opts: &PropCheck.TestHelpers.config/0
  use PropCheck.StateM
  use ExUnit.Case

  property "Counter GenServer State Test #{:rand.uniform()}" do
    trap_exit(
      forall cmds <- commands(__MODULE__) do
        IO.puts("--------------------------------------------------------------------------------")
        CounterStateTest.Counter.start_link()
        {_history, _state, result} = run_commands(__MODULE__, cmds)
        result == :ok
      end
    )
  end

  def initial_state, do: %{count: 0}

  # def command(%{count: _}) do
  #   {:call, CounterStateTest.Counter, :increment, []}
  # end

  def command(_state) do
    oneof([
      {:call, CounterStateTest.Counter, :increment, []},
      {:call, CounterStateTest.Counter, :decrement, []}
      # {:call, CounterStateTest.Counter, :get_value, []},
      # {:call, CounterStateTest.Counter, :reset, []}
    ])
  end


  def next_state(%{count: count} = state, res, cmd = {:call, CounterStateTest.Counter, :increment, []}) do
    IO.inspect({state, res, cmd}, label: Color.purple("next_state/3 :increment"))
    Map.replace(state, :count, count + 1)|> IO.inspect()
  end

  def next_state(%{count: count} = state, res, {:call, CounterStateTest.Counter, :decrement, []}) do
    IO.inspect(state,  label: Color.green("next_state/3 :decrement"))
    Map.replace(state, :count, count - 1)|> IO.inspect()
  end

  # def next_state(_state, _res, {:call, CounterStateTest.Counter, :reset, []}) do
  #   %{count: 0}
  # end

  # def next_state(state, _res, call) do
  #   IO.inspect(call, label: Color.red("Call"))

  #   state
  # end

  def precondition(_state, _command) do
    true
  end

  def postcondition(state, {:call, CounterStateTest.Counter, :increment, []}, result) do
    IO.inspect({state, result}, label: Color.red("Increment"))
    result == state.count
  end

  def postcondition(state, {:call, CounterStateTest.Counter, :decrement, []}, result) do
    IO.inspect({state, result}, label: Color.purple("Decrement"))
    result == state.count
  end

  def postcondition(state, {:call, CounterStateTest.Counter, :get_value, []}, result) do
    assert result == state.count
  end

  def postcondition(_state, {:call, CounterStateTest.Counter, :reset, []}, result) do
    assert result == 0
  end

  # initial_state/0
  # command/1
  # precondition/2
  # postcondition/3
  # next_state/3

  defmodule Counter do
    @moduledoc """
    A GenServer template for a "singleton" process.
    """
    use GenServer

    # Initialization
    def start_link(opts \\ []) do
      GenServer.start_link(__MODULE__, opts, name: __MODULE__)
    end

    def init(_opts) do
      state = %{
        count: 0
      }

      {:ok, state}
    end

    # API
    def increment() do
      GenServer.call(__MODULE__, :increment)
    end

    def decrement() do
      GenServer.call(__MODULE__, :decrement)
    end

    def get_value() do
      GenServer.call(__MODULE__, :get_value)
    end

    def reset() do
      GenServer.call(__MODULE__, :reset)
    end

    # Callbacks
    def handle_call(:increment, _from, state = %{count: count}) do
      state = %{state | count: count + 1}

      {:reply, state.count, state}
    end

    def handle_call(:decrement, _from, _state = %{count: 4}) do
      throw(:FAKE_ERROR)
    end

    def handle_call(:decrement, _from, state = %{count: count}) do
      state = %{state | count: count - 1}
      {:reply, state.count, state}
    end

    def handle_call(:get_value, _from, state = %{count: _count}) do
      {:reply, state.count, state}
    end

    def handle_call(:reset, _from, state) do
      state = %{state | count: 0}
      {:reply, 0, state}
    end
  end
end
