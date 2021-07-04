defmodule SkyRealmRestaurant.Core.Simulator.Server do
  use GenServer, restart: :permanent

  def start_link(initial_state),
    do: GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)

  def init(state) do
    Process.send_after(self(), :process, 500)
    {:ok, state}
  end

  def handle_info(:process, state = %{simulators: simulators}) do
    updated_state = run_simulators(simulators, state)
    Process.send_after(self(), :process, 500)
    {:noreply, updated_state}
  end

  def run_simulators([], state), do: state

  def run_simulators([simulator | simulators], state) do
    {:ok, updated_state} = simulator.process(state)
    updated_state = Map.merge(state, updated_state)
    run_simulators(simulators, updated_state)
  end
end
