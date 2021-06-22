defmodule SkyRealmRestaurant.Controllers.FinalProductController do
  alias SkyRealmRestaurant.Entities.FinalProduct
  alias SkyRealmRestaurant.Services.InMemoryStore.FinalProductService

  def find_by_id(id), do: FinalProductService.find_by_id(id)

  def find_all(), do: FinalProductService.find_all()

  def create(new_final_product = %FinalProduct{}),
    do: FinalProductService.create(new_final_product)

  def update(id, updated_final_product = %FinalProduct{}),
    do: FinalProductService.update(id, updated_final_product)

  def delete(id), do: FinalProductService.delete(id)
end
