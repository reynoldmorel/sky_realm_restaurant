defmodule SkyRealmRestaurant.Utils.KitchenSimulatorUtils do
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailService
  alias SkyRealmRestaurant.Services.InMemoryStore.StatusHistoryService
  alias SkyRealmRestaurant.Services.InMemoryStore.ChefService

  alias SkyRealmRestaurant.Constants.PreparationStatus
  alias SkyRealmRestaurant.Constants.ModelType
  alias SkyRealmRestaurant.Constants.ProcessingStatus
  alias SkyRealmRestaurant.Constants.ChefWorkingStatus

  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Entities.StatusHistory
  alias SkyRealmRestaurant.Entities.Chef

  alias SkyRealmRestaurant.Core.Queue
  alias SkyRealmRestaurant.Core.QueueItem

  def insert_order_details_in_queue(queue, []), do: {:ok, queue}

  def insert_order_details_in_queue(queue = %Queue{}, [order_detail | order_details]) do
    {:ok, updated_queue} = Queue.enqueue(%QueueItem{order_detail_id: order_detail.id}, queue)

    insert_order_details_in_queue(updated_queue, order_details)
  end

  def update_status_history_from_preparation_status(
        order_detail = %OrderDetail{},
        preparation_status,
        chef_id
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
          to_time: current_date_unix,
          assigned_chef_id: chef_id
        })

      nil ->
        StatusHistoryService.create(%StatusHistory{
          model_id: order_detail.id,
          model_type: ModelType.order_detail(),
          from_status: order_detail.preparation_status,
          to_status: preparation_status,
          from_time: order_detail.created_at,
          to_time: current_date_unix,
          assigned_chef_id: chef_id
        })
    end
  end

  def update_order_detail(
        order_details,
        preparation_status,
        processing_status,
        chef_id \\ nil
      )

  def update_order_detail(
        [],
        _preparation_status,
        _processing_status,
        _chef_id
      ),
      do: {:ok}

  def update_order_detail(
        [order_detail = %OrderDetail{} | order_details],
        preparation_status,
        processing_status,
        chef_id
      ) do
    preparation_status =
      case preparation_status != nil do
        true -> preparation_status
        false -> order_detail.preparation_status
      end

    processing_status =
      case processing_status != nil do
        true -> processing_status
        false -> order_detail.processing_status
      end

    case OrderDetailService.update(order_detail.id, %OrderDetail{
           order_detail
           | preparation_status: preparation_status,
             processing_status: processing_status
         }) do
      {:ok, _} ->
        {:ok, _} =
          update_status_history_from_preparation_status(order_detail, preparation_status, chef_id)

        update_order_detail(
          order_details,
          preparation_status,
          processing_status,
          chef_id
        )

      error ->
        error
    end
  end

  def assign_chefs([], ready_queue = %Queue{}, preparing_queue = %Queue{}),
    do: {:ok, ready_queue, preparing_queue}

  def assign_chefs([chef = %Chef{} | chefs], ready_queue = %Queue{}, preparing_queue = %Queue{}) do
    {:ok, queue_item, updated_ready_queue} = Queue.dequeue(ready_queue)

    case queue_item != nil do
      true ->
        {:ok, order_detail} = OrderDetailService.find_by_id_enabled(queue_item.order_detail_id)

        {:ok} =
          update_order_detail(
            [order_detail],
            PreparationStatus.preparing(),
            ProcessingStatus.enqueue(),
            chef.id
          )

        {:ok, updated_preparing_queue} =
          insert_order_details_in_queue(preparing_queue, [order_detail])

        {:ok, _} =
          ChefService.update(chef.id, %Chef{chef | working_status: ChefWorkingStatus.busy()})

        assign_chefs(chefs, updated_ready_queue, updated_preparing_queue)

      false ->
        {:ok, ready_queue, preparing_queue}
    end
  end
end
