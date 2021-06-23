defmodule SkyRealmRestaurant.Controllers.OrderDetailController do
  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailService

  def find_by_id(id), do: OrderDetailService.find_by_id(id)

  def find_all(), do: OrderDetailService.find_all()

  def create(new_order_detail = %OrderDetail{}), do: OrderDetailService.create(new_order_detail)

  def update(id, updated_order_detail = %OrderDetail{}),
    do: OrderDetailService.update(id, updated_order_detail)

  def delete(id), do: OrderDetailService.delete(id)
end
