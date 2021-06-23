defmodule SkyRealmRestaurant.Controllers.CategoryController do
  alias SkyRealmRestaurant.Entities.Category
  alias SkyRealmRestaurant.Services.InMemoryStore.CategoryService

  def find_by_id(id), do: CategoryService.find_by_id(id)

  def find_all(), do: CategoryService.find_all()

  def create(new_category = %Category{}), do: CategoryService.create(new_category)

  def update(id, updated_category = %Category{}), do: CategoryService.update(id, updated_category)

  def delete(id), do: CategoryService.delete(id)
end
