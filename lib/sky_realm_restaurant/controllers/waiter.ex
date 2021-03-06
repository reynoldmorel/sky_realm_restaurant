defmodule SkyRealmRestaurant.Controllers.WaiterController do
  alias SkyRealmRestaurant.Entities.Waiter
  alias SkyRealmRestaurant.Services.InMemoryStore.WaiterService

  def find_by_id(id), do: WaiterService.find_by_id(id)

  def find_all(), do: WaiterService.find_all()

  def find_by_id_enabled(id), do: WaiterService.find_by_id_enabled(id)

  def find_all_enabled(), do: WaiterService.find_all_enabled()

  def find_by_username_enabled(id), do: WaiterService.find_by_username_enabled(id)

  def create(new_waiter = %Waiter{}), do: WaiterService.create(new_waiter)

  def update(id, updated_waiter = %Waiter{}), do: WaiterService.update(id, updated_waiter)

  def delete(id), do: WaiterService.delete(id)
end
