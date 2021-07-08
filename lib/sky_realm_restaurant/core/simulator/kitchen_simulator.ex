defmodule SkyRealmRestaurant.Core.Simulator.KitchenSimulator do
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailService
  alias SkyRealmRestaurant.Services.InMemoryStore.StatusHistoryService
  alias SkyRealmRestaurant.Services.InMemoryStore.ChefService

  alias SkyRealmRestaurant.Constants.PreparationStatus
  alias SkyRealmRestaurant.Constants.CookingStep
  alias SkyRealmRestaurant.Constants.ModelType

  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Entities.StatusHistory

  alias SkyRealmRestaurant.Utils.InventoryUtils
  alias SkyRealmRestaurant.Utils.KitchenSimulatorUtils

  alias SkyRealmRestaurant.Core.Queue

  def process(state = %{kitchen_simulator_state: _kitchen_simulator_state}) do
    {:ok, updated_state} = process(:place_orders_ready_to_be_worked, state)
    updated_state = Map.merge(state, updated_state)
    {:ok, updated_state} = process(:assign_new_orders_to_chefs, updated_state)
    updated_state = Map.merge(state, updated_state)
    {:ok, updated_state} = process(:start_order_cooking_step, updated_state)
    updated_state = Map.merge(state, updated_state)
    {:ok, updated_state} = process(:update_order_cooking_step, updated_state)
    updated_state = Map.merge(state, updated_state)
    {:ok, updated_state} = process(:release_completed_orders, updated_state)
    {:ok, Map.merge(state, updated_state)}
    {:ok, updated_state} = process(:clean_up, updated_state)
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
        PreparationStatus.ready()
      )

    {:ok} =
      KitchenSimulatorUtils.update_order_detail(
        order_details_to_cancel,
        PreparationStatus.canceled()
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

  def process(
        :start_order_cooking_step,
        state = %{kitchen_simulator_state: kitchen_simulator_state}
      ) do
    %{queues: queues} = kitchen_simulator_state

    preparing_status = PreparationStatus.preparing()
    preparing_queue = Map.get(queues, preparing_status)

    {:ok, queue_item, updated_preparing_queue} = Queue.dequeue(preparing_queue)

    updated_queues =
      case queue_item != nil do
        true ->
          {:ok, order_detail_to_prepare} =
            OrderDetailService.find_to_prepare_by_id_enabled(queue_item.order_detail_id)

          {:ok, updated_queues} =
            KitchenSimulatorUtils.start_cooking_step([order_detail_to_prepare], queues)

          Map.put(updated_queues, preparing_status, updated_preparing_queue)

        false ->
          queues
      end

    {:ok,
     Map.merge(state, %{
       kitchen_simulator_state: Map.merge(kitchen_simulator_state, %{queues: updated_queues})
     })}
  end

  def process(
        :update_order_cooking_step,
        state = %{kitchen_simulator_state: kitchen_simulator_state}
      ) do
    %{queues: queues} = kitchen_simulator_state

    {:ok, updated_queues} =
      KitchenSimulatorUtils.update_cooking_steps(CookingStep.get_values(), queues)

    {:ok,
     Map.merge(state, %{
       kitchen_simulator_state: Map.merge(kitchen_simulator_state, %{queues: updated_queues})
     })}
  end

  def process(
        :release_completed_orders,
        state = %{kitchen_simulator_state: kitchen_simulator_state}
      ) do
    %{queues: queues} = kitchen_simulator_state

    cooking_step_completed = CookingStep.completed()
    cooking_step_completed_queue = Map.get(queues, cooking_step_completed.name)

    {:ok, queue_item, updated_cooking_step_completed_queue} =
      Queue.dequeue(cooking_step_completed_queue)

    updated_queues =
      case queue_item != nil do
        true ->
          completed_status = PreparationStatus.completed()
          completed_status_queue = Map.get(queues, completed_status)

          {:ok, order_detail = %OrderDetail{}} =
            OrderDetailService.find_by_id_enabled(queue_item.order_detail_id)

          {:ok, %StatusHistory{assigned_chef_id: chef_id}} =
            StatusHistoryService.find_last_by_model_id_and_model_type_enabled(
              queue_item.order_detail_id,
              ModelType.order_detail()
            )

          {:ok} =
            KitchenSimulatorUtils.update_order_detail(
              [order_detail],
              PreparationStatus.completed(),
              chef_id
            )

          {:ok, updated_completed_status_queue} =
            Queue.enqueue(queue_item, completed_status_queue)

          updated_queues =
            Map.put(queues, cooking_step_completed.name, updated_cooking_step_completed_queue)

          Map.put(updated_queues, completed_status, updated_completed_status_queue)

        false ->
          queues
      end

    {:ok,
     Map.merge(state, %{
       kitchen_simulator_state: Map.merge(kitchen_simulator_state, %{queues: updated_queues})
     })}
  end

  def process(
        :clean_up,
        state = %{kitchen_simulator_state: kitchen_simulator_state}
      ) do
    %{queues: queues} = kitchen_simulator_state

    completed_status = PreparationStatus.completed()
    completed_status_queue = Map.get(queues, completed_status)

    {:ok, _queue_item, updated_completed_status_queue} = Queue.dequeue(completed_status_queue)

    updated_queues = Map.put(queues, completed_status, updated_completed_status_queue)

    {:ok,
     Map.merge(state, %{
       kitchen_simulator_state: Map.merge(kitchen_simulator_state, %{queues: updated_queues})
     })}
  end
end
