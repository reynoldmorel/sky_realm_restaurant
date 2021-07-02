defmodule SkyRealmRestaurant.Core.Simulator.KitchenSimulator do
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailService
  alias SkyRealmRestaurant.Services.InMemoryStore.StatusHistoryService

  alias SkyRealmRestaurant.Constants.PreparationStatus
  alias SkyRealmRestaurant.Constants.ModelType

  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Entities.StatusHistory

  alias SkyRealmRestaurant.Core.Queue

  alias SkyRealmRestaurant.Utils.InventoryUtils

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

  defp insert_order_details_in_queue(queue, []), do: {:ok, queue}

  defp insert_order_details_in_queue(queue = %Queue{}, [order_detail | order_details]) do
    {:ok, updated_queue} = Queue.enqueue(order_detail, queue)

    insert_order_details_in_queue(updated_queue, order_details)
  end

  defp update_status_history_from_preparation_status(
         order_detail = %OrderDetail{},
         preparation_status
       ) do
    {:ok, previous_status_history} =
      StatusHistoryService.find_by_model_id_and_model_type_and_to_status_enabled(
        order_detail.id,
        ModelType.order_detail(),
        order_detail.preparation_status
      )

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    case previous_status_history do
      previous_status_history = %StatusHistory{} ->
        StatusHistoryService.create(%StatusHistory{
          model_id: order_detail.id,
          model_type: ModelType.order_detail(),
          from_status: previous_status_history.to_status,
          to_status: preparation_status,
          from_time: previous_status_history.to_time,
          to_time: current_date_unix
        })

      nil ->
        StatusHistoryService.create(%StatusHistory{
          model_id: order_detail.id,
          model_type: ModelType.order_detail(),
          from_status: order_detail.preparation_status,
          to_status: preparation_status,
          from_time: order_detail.created_at,
          to_time: current_date_unix
        })
    end
  end

  defp update_order_detail_preparation_status([], _preparation_status), do: {:ok}

  defp update_order_detail_preparation_status(
         [order_detail = %OrderDetail{} | order_details],
         preparation_status
       ) do
    preparation_status =
      case preparation_status != nil do
        true -> preparation_status
        false -> order_detail.preparation_status
      end

    case OrderDetailService.update(order_detail.id, %OrderDetail{
           order_detail
           | preparation_status: preparation_status
         }) do
      {:ok, _} ->
        {:ok, _} = update_status_history_from_preparation_status(order_detail, preparation_status)
        update_order_detail_preparation_status(order_details, preparation_status)

      error ->
        error
    end
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

    {:ok, updated_ready_queue} = insert_order_details_in_queue(ready_queue, valid_order_details)

    {:ok} = update_order_detail_preparation_status(valid_order_details, PreparationStatus.ready())

    {:ok} =
      update_order_detail_preparation_status(
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
