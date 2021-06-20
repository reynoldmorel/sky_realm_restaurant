defmodule SkyRealmRestaurant.Constants.ProcessingStatus do
  @values ["enqueue", "processing"]

  def get_values, do: @values

  def get_enqueue_index, do: 0

  def get_processing_index, do: 1

  def enqueue, do: get_values() |> Enum.at(get_enqueue_index())

  def processing, do: get_values() |> Enum.at(get_processing_index())
end
