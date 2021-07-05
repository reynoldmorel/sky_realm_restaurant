defmodule SkyRealmRestaurant.Constants.Status do
  @values ["status_enable", "status_deleted"]

  def get_values, do: @values

  def get_enable_index, do: 0

  def get_deleted_index, do: 1

  def enable, do: get_values() |> Enum.at(get_enable_index())

  def deleted, do: get_values() |> Enum.at(get_deleted_index())
end
