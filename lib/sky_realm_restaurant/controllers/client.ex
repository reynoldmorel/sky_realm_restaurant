defmodule SkyRealmRestaurant.Controllers.ClientController do
  alias SkyRealmRestaurant.Entities.Client
  alias SkyRealmRestaurant.Services.InMemoryStore.ClientService

  def find_by_id(id), do: ClientService.find_by_id(id)

  def find_all(), do: ClientService.find_all()

  def find_by_id_enabled(id), do: ClientService.find_by_id_enabled(id)

  def find_all_enabled(), do: ClientService.find_all_enabled()

  def find_by_username_enabled(id), do: ClientService.find_by_username_enabled(id)

  def create(new_client = %Client{}), do: ClientService.create(new_client)

  def update(id, updated_client = %Client{}), do: ClientService.update(id, updated_client)

  def delete(id), do: ClientService.delete(id)
end
