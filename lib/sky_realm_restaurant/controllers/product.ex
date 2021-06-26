defmodule SkyRealmRestaurant.Controllers.ProductController do
  alias SkyRealmRestaurant.Entities.Product
  alias SkyRealmRestaurant.Services.InMemoryStore.ProductService

  def find_by_id(id), do: ProductService.find_by_id(id)

  def find_all(), do: ProductService.find_all()

  def find_by_id_enabled(id), do: ProductService.find_by_id_enabled(id)

  def find_all_enabled(), do: ProductService.find_all_enabled()

  def find_by_serial_enabled(serial), do: ProductService.find_by_serial_enabled(serial)

  def create(new_product = %Product{}),
    do: ProductService.create(new_product)

  def update(id, updated_product = %Product{}),
    do: ProductService.update(id, updated_product)

  def delete(id), do: ProductService.delete(id)
end
