defmodule SkyRealmRestaurant.Controllers.OrderController do
  alias SkyRealmRestaurant.Entities.Order
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderService

  def find_by_id(id), do: OrderService.find_by_id(id)

  def find_all(), do: OrderService.find_all()

  def find_by_id_enabled(id), do: OrderService.find_by_id_enabled(id)

  def find_all_enabled(), do: OrderService.find_all_enabled()

  def create(new_order = %Order{}), do: OrderService.create(new_order)

  def update(id, updated_order = %Order{}),
    do: OrderService.update(id, updated_order)

  def delete(id), do: OrderService.delete(id)
end
