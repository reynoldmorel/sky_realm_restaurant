defmodule SkyRealmRestaurant.Controllers.OrderDetailController do
  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailService

  def find_by_id(id), do: OrderDetailService.find_by_id(id)

  def find_all(), do: OrderDetailService.find_all()

  def find_by_id_enabled(id), do: OrderDetailService.find_by_id_enabled(id)

  def find_all_enabled(), do: OrderDetailService.find_all_enabled()

  def find_all_by_order_id_enabled(order_id),
    do: OrderDetailService.find_all_by_order_id_enabled(order_id)

  def find_all_ready_to_work_enabled(), do: OrderDetailService.find_all_ready_to_work_enabled()

  def find_all_to_prepare_enabled(), do: OrderDetailService.find_all_to_prepare_enabled()

  def find_to_prepare_by_id_enabled(id), do: OrderDetailService.find_to_prepare_by_id_enabled(id)

  def create(new_order_detail = %OrderDetail{}), do: OrderDetailService.create(new_order_detail)

  def update(id, updated_order_detail = %OrderDetail{}),
    do: OrderDetailService.update(id, updated_order_detail)

  def delete(id), do: OrderDetailService.delete(id)
end
