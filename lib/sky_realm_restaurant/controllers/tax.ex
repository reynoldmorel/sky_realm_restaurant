defmodule SkyRealmRestaurant.Controllers.TaxController do
  alias SkyRealmRestaurant.Entities.Tax
  alias SkyRealmRestaurant.Services.InMemoryStore.TaxService

  def find_by_id(id), do: TaxService.find_by_id(id)

  def find_all(), do: TaxService.find_all()

  def find_by_id_enabled(id), do: TaxService.find_by_id_enabled(id)

  def find_all_enabled(), do: TaxService.find_all_enabled()

  def create(new_tax = %Tax{}), do: TaxService.create(new_tax)

  def update(id, updated_tax = %Tax{}), do: TaxService.update(id, updated_tax)

  def delete(id), do: TaxService.delete(id)
end
