defmodule SkyRealmRestaurant.Utils.KitchenSimulatorUtils do
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailService
  alias SkyRealmRestaurant.Services.InMemoryStore.StatusHistoryService
  alias SkyRealmRestaurant.Services.InMemoryStore.ChefService
  alias SkyRealmRestaurant.Services.InMemoryStore.FinalProductService
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailProductService

  alias SkyRealmRestaurant.Constants.PreparationStatus
  alias SkyRealmRestaurant.Constants.ModelType
  alias SkyRealmRestaurant.Constants.ChefWorkingStatus
  alias SkyRealmRestaurant.Constants.CookingStep

  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Entities.StatusHistory
  alias SkyRealmRestaurant.Entities.Chef
  alias SkyRealmRestaurant.Entities.OrderDetailProduct
  alias SkyRealmRestaurant.Entities.FinalProduct

  alias SkyRealmRestaurant.Core.Queue
  alias SkyRealmRestaurant.Core.QueueItem

  alias SkyRealmRestaurant.Utils.GeneralUtils

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
        chef_id \\ nil
      )

  def update_order_detail(
        [],
        _preparation_status,
        _chef_id
      ),
      do: {:ok}

  def update_order_detail(
        [order_detail = %OrderDetail{} | order_details],
        preparation_status,
        chef_id
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
        {:ok, _} =
          update_status_history_from_preparation_status(order_detail, preparation_status, chef_id)

        update_order_detail(
          order_details,
          preparation_status,
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

  def is_time_to_change_cooking_step(nil, _assigned_chef, _final_product_chef, _limit),
    do: {:ok, true}

  def is_time_to_change_cooking_step(
        %StatusHistory{to_time: initial_time},
        %Chef{experience_level: chef_experience_level},
        %FinalProduct{difficulty_level: product_difficulty_level},
        step_delay
      ) do
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    current_date_unix = current_date_unix - product_difficulty_level / chef_experience_level * 20

    {:ok, current_date_unix - initial_time > step_delay}
  end

  def start_cooking_step([], queues_map),
    do: {:ok, queues_map}

  def start_cooking_step(
        [order_detail = %OrderDetail{} | order_details],
        queues_map = %{}
      ) do
    {:ok, [order_detail_product = %OrderDetailProduct{} | _]} =
      OrderDetailProductService.find_all_by_order_detail_id_enabled(order_detail.id)

    case order_detail_product.is_final_product do
      true ->
        {:ok, final_product = %FinalProduct{}} =
          FinalProductService.find_by_id_enabled(order_detail_product.product_id)

        current_date_unix = DateTime.to_unix(DateTime.utc_now())

        final_product_steps =
          final_product.cooking_steps
          |> Enum.map(fn fp_cooking_step ->
            struct(
              CookingStep,
              GeneralUtils.convert_map_to_keyword_list(fp_cooking_step)
            )
          end)

        cooking_step =
          case order_detail.cooking_step do
            nil ->
              nil

            cooking_step ->
              struct(
                CookingStep,
                GeneralUtils.convert_map_to_keyword_list(cooking_step)
              )
          end

        {:ok, next_cooking_step} = get_next_cooking_step(final_product_steps, cooking_step)

        {:ok, parent_status_history = %StatusHistory{}} =
          StatusHistoryService.find_by_model_id_and_model_type_and_to_status_enabled(
            order_detail.id,
            ModelType.order_detail(),
            order_detail.preparation_status
          )

        {:ok, _} =
          StatusHistoryService.create(%StatusHistory{
            parent_id: parent_status_history.id,
            model_id: final_product.id,
            model_type: ModelType.final_product(),
            from_status: nil,
            to_status: next_cooking_step.name,
            from_time: parent_status_history.to_time,
            to_time: current_date_unix,
            assigned_chef_id: parent_status_history.assigned_chef_id
          })

        {:ok, _} =
          OrderDetailService.update(order_detail.id, %OrderDetail{
            order_detail
            | cooking_step: next_cooking_step
          })

        next_cooking_step_queue = Map.get(queues_map, next_cooking_step.name)

        {:ok, updated_next_cooking_step_queue} =
          Queue.enqueue(
            %QueueItem{
              order_detail_id: order_detail.id,
              final_product_id: final_product.id
            },
            next_cooking_step_queue
          )

        updated_queues_map =
          Map.put(queues_map, next_cooking_step.name, updated_next_cooking_step_queue)

        start_cooking_step(order_details, updated_queues_map)

      false ->
        start_cooking_step(order_details, queues_map)
    end
  end

  def update_cooking_steps([], queues_map),
    do: {:ok, queues_map}

  def update_cooking_steps([cooking_step = %{} | cooking_steps], queues_map = %{}) do
    cooking_step =
      struct(
        CookingStep,
        GeneralUtils.convert_map_to_keyword_list(cooking_step)
      )

    cooking_step_queue = Map.get(queues_map, cooking_step.name)

    {:ok, queue_item, updated_cooking_step_queue} = Queue.dequeue(cooking_step_queue)

    case queue_item != nil do
      true ->
        {:ok, order_detail = %OrderDetail{}} =
          OrderDetailService.find_by_id_enabled(queue_item.order_detail_id)

        {:ok, final_product = %FinalProduct{}} =
          FinalProductService.find_by_id_enabled(queue_item.final_product_id)

        current_date_unix = DateTime.to_unix(DateTime.utc_now())

        final_product_steps =
          final_product.cooking_steps
          |> Enum.map(fn fp_cooking_step ->
            struct(
              CookingStep,
              GeneralUtils.convert_map_to_keyword_list(fp_cooking_step)
            )
          end)

        {:ok, next_cooking_step} = get_next_cooking_step(final_product_steps, cooking_step)

        {:ok, parent_status_history = %StatusHistory{}} =
          StatusHistoryService.find_by_model_id_and_model_type_and_to_status_enabled(
            order_detail.id,
            ModelType.order_detail(),
            order_detail.preparation_status
          )

        {:ok, assigned_chef = %Chef{}} =
          ChefService.find_by_id_enabled(parent_status_history.assigned_chef_id)

        {:ok, last_final_product_status_history} =
          StatusHistoryService.find_last_by_parent_id_and_model_type_enabled(
            parent_status_history.id,
            ModelType.final_product()
          )

        {:ok, change_cooking_step} =
          is_time_to_change_cooking_step(
            last_final_product_status_history,
            assigned_chef,
            final_product,
            cooking_step.default_timeout_sec
          )

        case change_cooking_step and next_cooking_step != nil do
          true ->
            {:ok, _} =
              StatusHistoryService.create(%StatusHistory{
                parent_id: parent_status_history.id,
                model_id: final_product.id,
                model_type: ModelType.final_product(),
                from_status: cooking_step.name,
                to_status: next_cooking_step.name,
                from_time: last_final_product_status_history.to_time,
                to_time: current_date_unix,
                assigned_chef_id: last_final_product_status_history.assigned_chef_id
              })

            {:ok, _} =
              OrderDetailService.update(order_detail.id, %OrderDetail{
                order_detail
                | cooking_step: next_cooking_step
              })

            next_cooking_step_queue = Map.get(queues_map, next_cooking_step.name)

            {:ok, updated_next_cooking_step_queue} =
              Queue.enqueue(queue_item, next_cooking_step_queue)

            updated_queues_map =
              Map.put(
                queues_map,
                cooking_step.name,
                updated_cooking_step_queue
              )

            updated_queues_map =
              Map.put(
                updated_queues_map,
                next_cooking_step.name,
                updated_next_cooking_step_queue
              )

            update_cooking_steps(cooking_steps, updated_queues_map)

          false ->
            update_cooking_steps(cooking_steps, queues_map)
        end

      false ->
        update_cooking_steps(cooking_steps, queues_map)
    end
  end

  def get_next_cooking_step(
        cooking_steps,
        current_cooking_step,
        previous_cooking_step \\ nil
      )

  def get_next_cooking_step(
        [],
        _current_cooking_step,
        _previous_cooking_step
      ),
      do: {:ok, nil}

  def get_next_cooking_step(
        [
          cooking_step = %CookingStep{} | _cooking_steps
        ],
        nil,
        _previous_cooking_step
      ),
      do: {:ok, cooking_step}

  def get_next_cooking_step(
        [
          cooking_step = %CookingStep{} | cooking_steps
        ],
        current_cooking_step,
        nil
      ),
      do: get_next_cooking_step(cooking_steps, current_cooking_step, cooking_step)

  def get_next_cooking_step(
        [
          cooking_step = %CookingStep{} | cooking_steps
        ],
        current_cooking_step = %CookingStep{name: current_cooking_step_name},
        %CookingStep{name: previous_cooking_step_name}
      ) do
    case current_cooking_step_name == previous_cooking_step_name do
      true -> {:ok, cooking_step}
      false -> get_next_cooking_step(cooking_steps, current_cooking_step, cooking_step)
    end
  end
end
