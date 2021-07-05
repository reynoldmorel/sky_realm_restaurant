defmodule SkyRealmRestaurant.Constants.PreparationStatus do
  @values [
    "preparation_status_ready",
    "preparation_status_preparing",
    "preparation_status_completed",
    "preparation_status_canceled"
  ]

  def get_values, do: @values

  def get_ready_index, do: 0

  def get_preparing_index, do: 1

  def get_completed_index, do: 2

  def get_canceled_index, do: 3

  def ready, do: get_values() |> Enum.at(get_ready_index())

  def preparing, do: get_values() |> Enum.at(get_preparing_index())

  def completed, do: get_values() |> Enum.at(get_completed_index())

  def canceled, do: get_values() |> Enum.at(get_canceled_index())
end
