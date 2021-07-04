defmodule SkyRealmRestaurant.Core.Simulator.KitchenSimulator do
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailService
  alias SkyRealmRestaurant.Services.InMemoryStore.ChefService

  alias SkyRealmRestaurant.Constants.PreparationStatus
  alias SkyRealmRestaurant.Constants.ProcessingStatus

  alias SkyRealmRestaurant.Entities.OrderDetail

  alias SkyRealmRestaurant.Utils.InventoryUtils
  alias SkyRealmRestaurant.Utils.KitchenSimulatorUtils

  def process(state = %{kitchen_simulator_state: _kitchen_simulator_state}) do
    {:ok, updated_state} = process(:place_orders_ready_to_be_worked, state)
    updated_state = Map.merge(state, updated_state)
    {:ok, updated_state} = process(:assign_new_orders_to_chefs, updated_state)
    updated_state = Map.merge(state, updated_state)
    {:ok, updated_state} = process(:update_order_status, updated_state)
    updated_state = Map.merge(state, updated_state)
    {:ok, updated_state} = process(:release_completed_orders, updated_state)
    {:ok, Map.merge(state, updated_state)}
  end

  def process(
        :place_orders_ready_to_be_worked,
        state = %{kitchen_simulator_state: kitchen_simulator_state}
      ) do
    {:ok, order_details_to_work} = OrderDetailService.find_all_ready_to_work_enabled()

    %{queues: queues} = kitchen_simulator_state

    ready_status = PreparationStatus.ready()
    ready_queue = Map.get(queues, ready_status)

    {:ok, validated_map} =
      InventoryUtils.validate_order_details_and_update_inventory(order_details_to_work)

    valid_order_details =
      order_details_to_work
      |> Enum.filter(fn %OrderDetail{id: order_detail_id} ->
        Map.get(validated_map, order_detail_id)
      end)

    order_details_to_cancel =
      order_details_to_work
      |> Enum.filter(fn %OrderDetail{id: order_detail_id} ->
        not Map.get(validated_map, order_detail_id)
      end)

    {:ok, updated_ready_queue} =
      KitchenSimulatorUtils.insert_order_details_in_queue(ready_queue, valid_order_details)

    {:ok} =
      KitchenSimulatorUtils.update_order_detail(
        valid_order_details,
        PreparationStatus.ready(),
        ProcessingStatus.enqueue()
      )

    {:ok} =
      KitchenSimulatorUtils.update_order_detail(
        order_details_to_cancel,
        PreparationStatus.canceled(),
        ProcessingStatus.enqueue()
      )

    updated_queues = Map.put(queues, ready_status, updated_ready_queue)

    {:ok,
     Map.merge(state, %{
       kitchen_simulator_state: Map.merge(kitchen_simulator_state, %{queues: updated_queues})
     })}
  end

  def process(
        :assign_new_orders_to_chefs,
        state = %{kitchen_simulator_state: kitchen_simulator_state}
      ) do
    %{queues: queues} = kitchen_simulator_state

    {:ok, available_chefs} = ChefService.find_all_available()

    ready_status = PreparationStatus.ready()
    ready_queue = Map.get(queues, ready_status)

    preparing_status = PreparationStatus.preparing()
    preparing_queue = Map.get(queues, preparing_status)

    {:ok, updated_ready_queue, updated_preparing_queue} =
      KitchenSimulatorUtils.assign_chefs(available_chefs, ready_queue, preparing_queue)

    updated_queues = Map.put(queues, ready_status, updated_ready_queue)
    updated_queues = Map.put(updated_queues, preparing_status, updated_preparing_queue)

    {:ok,
     Map.merge(state, %{
       kitchen_simulator_state: Map.merge(kitchen_simulator_state, %{queues: updated_queues})
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
