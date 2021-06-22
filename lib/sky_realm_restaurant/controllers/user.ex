defmodule SkyRealmRestaurant.Controllers.UserController do
  alias SkyRealmRestaurant.Entities.User
  alias SkyRealmRestaurant.Services.InMemoryStore.UserService

  def find_by_id(id), do: UserService.find_by_id(id)

  def find_all(), do: UserService.find_all()

  def create(new_user = %User{}), do: UserService.create(new_user)

  def update(id, updated_user = %User{}), do: UserService.update(id, updated_user)

  def delete(id), do: UserService.delete(id)
end
