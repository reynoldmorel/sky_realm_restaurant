defmodule SkyRealmRestaurant.Constants.PreparationStatus do
  @values ["ready", "preparing", "completed", "cancelled"]

  def get_values, do: @values

  def get_ready_index, do: 0

  def get_preparing_index, do: 1

  def get_completed_index, do: 2

  def get_cancelled_index, do: 3

  def ready, do: get_values() |> Enum.at(get_ready_index())

  def preparing, do: get_values() |> Enum.at(get_preparing_index())

  def completed, do: get_values() |> Enum.at(get_completed_index())

  def cancelled, do: get_values() |> Enum.at(get_cancelled_index())
end