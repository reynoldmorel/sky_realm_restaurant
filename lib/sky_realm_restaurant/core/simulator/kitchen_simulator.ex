defmodule SkyRealmRestaurant.Core.Simulator.KitchenSimulator do
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailService
  alias SkyRealmRestaurant.Services.InMemoryStore.ChefService

  def process(state = %{kitchen_simulator_state: _kitchen_simulator_state}) do
    {:ok, updated_state} = process(:assign_new_orders_to_chefs, state)
    updated_state = Map.merge(state, updated_state)
    {:ok, updated_state} = process(:update_order_status, updated_state)
    updated_state = Map.merge(state, updated_state)
    {:ok, updated_state} = process(:release_completed_orders, updated_state)
    {:ok, Map.merge(state, updated_state)}
  end

  def process(
        :assign_new_orders_to_chefs,
        state = %{kitchen_simulator_state: kitchen_simulator_state}
      ) do
    IO.puts("Assigning new orders to chefs")

    {:ok,
     Map.merge(state, %{
       kitchen_simulator_state: Map.merge(kitchen_simulator_state, %{testing1: 1})
     })}
  end

  def process(:update_order_status, state = %{kitchen_simulator_state: kitchen_simulator_state}) do
    IO.puts("Update order status")

    {:ok,
     Map.merge(state, %{
       kitchen_simulator_state: Map.merge(kitchen_simulator_state, %{testing2: 1})
     })}
  end

  def process(
        :release_completed_orders,
        state = %{kitchen_simulator_state: kitchen_simulator_state}
      ) do
    IO.puts("Release completed orders")

    {:ok,
     Map.merge(state, %{
       kitchen_simulator_state: Map.merge(kitchen_simulator_state, %{testing3: 1})
     })}
  end
end
