defmodule SkyRealmRestaurant.Controllers.ChefController do
  alias SkyRealmRestaurant.Entities.Chef
  alias SkyRealmRestaurant.Services.InMemoryStore.ChefService

  def find_by_id(id), do: ChefService.find_by_id(id)

  def find_all(), do: ChefService.find_all()

  def find_by_id_enabled(id), do: ChefService.find_by_id_enabled(id)

  def find_all_enabled(), do: ChefService.find_all_enabled()

  def find_by_username_enabled(id), do: ChefService.find_by_username_enabled(id)

  def find_all_available(), do: ChefService.find_all_available()

  def create(new_chef = %Chef{}), do: ChefService.create(new_chef)

  def update(id, updated_chef = %Chef{}), do: ChefService.update(id, updated_chef)

  def delete(id), do: ChefService.delete(id)
end
