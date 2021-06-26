defmodule SkyRealmRestaurant.Controllers.CashierController do
  alias SkyRealmRestaurant.Entities.Cashier
  alias SkyRealmRestaurant.Services.InMemoryStore.CashierService

  def find_by_id(id), do: CashierService.find_by_id(id)

  def find_all(), do: CashierService.find_all()

  def find_by_id_enabled(id), do: CashierService.find_by_id_enabled(id)

  def find_all_enabled(), do: CashierService.find_all_enabled()

  def find_by_username_enabled(id), do: CashierService.find_by_username_enabled(id)

  def create(new_cashier = %Cashier{}), do: CashierService.create(new_cashier)

  def update(id, updated_cashier = %Cashier{}), do: CashierService.update(id, updated_cashier)

  def delete(id), do: CashierService.delete(id)
end
