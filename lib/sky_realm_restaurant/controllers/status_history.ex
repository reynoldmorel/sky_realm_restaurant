defmodule SkyRealmRestaurant.Controllers.StatusHistoryController do
  alias SkyRealmRestaurant.Entities.StatusHistory
  alias SkyRealmRestaurant.Services.InMemoryStore.StatusHistoryService

  def find_by_id(id), do: StatusHistoryService.find_by_id(id)

  def find_all(), do: StatusHistoryService.find_all()

  def find_by_id_enabled(id), do: StatusHistoryService.find_by_id_enabled(id)

  def find_by_model_id_and_model_type_and_to_status_enabled(model_id, model_type, to_status),
    do:
      StatusHistoryService.find_by_model_id_and_model_type_and_to_status_enabled(
        model_id,
        model_type,
        to_status
      )

  def find_all_enabled(), do: StatusHistoryService.find_all_enabled()

  def find_last_by_parent_id_and_model_type_enabled(parent_id, model_type),
    do: StatusHistoryService.find_last_by_parent_id_and_model_type_enabled(parent_id, model_type)

  def create(new_status_history = %StatusHistory{}),
    do: StatusHistoryService.create(new_status_history)

  def update(id, updated_status_history = %StatusHistory{}),
    do: StatusHistoryService.update(id, updated_status_history)

  def delete(id), do: StatusHistoryService.delete(id)
end
