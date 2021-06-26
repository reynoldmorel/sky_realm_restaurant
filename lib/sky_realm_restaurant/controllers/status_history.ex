defmodule SkyRealmRestaurant.Controllers.StatusHistoryController do
  alias SkyRealmRestaurant.Entities.StatusHistory
  alias SkyRealmRestaurant.Services.InMemoryStore.StatusHistoryService

  def find_by_id(id), do: StatusHistoryService.find_by_id(id)

  def find_all(), do: StatusHistoryService.find_all()

  def find_by_id_enabled(id), do: StatusHistoryService.find_by_id_enabled(id)

  def find_all_enabled(), do: StatusHistoryService.find_all_enabled()

  def create(new_status_history = %StatusHistory{}),
    do: StatusHistoryService.create(new_status_history)

  def update(id, updated_status_history = %StatusHistory{}),
    do: StatusHistoryService.update(id, updated_status_history)

  def delete(id), do: StatusHistoryService.delete(id)
end
