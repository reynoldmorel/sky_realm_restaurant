defmodule SkyRealmRestaurant.Constants.ChefWorkingStatus do
  @values ["chef_working_status_idle", "chef_working_status_busy"]

  def get_values, do: @values

  def get_idle_index, do: 0

  def get_busy_index, do: 1

  def idle, do: get_values() |> Enum.at(get_idle_index())

  def busy, do: get_values() |> Enum.at(get_busy_index())
end
