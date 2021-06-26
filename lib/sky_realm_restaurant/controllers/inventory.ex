defmodule SkyRealmRestaurant.Controllers.InventoryController do
  alias SkyRealmRestaurant.Entities.Inventory
  alias SkyRealmRestaurant.Services.InMemoryStore.InventoryService

  def find_by_id(id), do: InventoryService.find_by_id(id)

  def find_all(), do: InventoryService.find_all()

  def find_by_id_enabled(id), do: InventoryService.find_by_id_enabled(id)

  def find_all_enabled(), do: InventoryService.find_all_enabled()

  def create(new_inventory = %Inventory{}), do: InventoryService.create(new_inventory)

  def update(id, updated_inventory = %Inventory{}),
    do: InventoryService.update(id, updated_inventory)

  def delete(id), do: InventoryService.delete(id)
end
