defmodule SkyRealmRestaurant.Constants.CookingStatus do
  @values ["frying", "boiling", "baking", "toasting"]

  def get_values, do: @values

  def get_frying_index, do: 0

  def get_boiling_index, do: 1

  def get_baking_index, do: 2

  def get_toasting_index, do: 3

  def frying, do: get_values() |> Enum.at(get_frying_index())

  def boiling, do: get_values() |> Enum.at(get_boiling_index())

  def baking, do: get_values() |> Enum.at(get_baking_index())

  def toasting, do: get_values() |> Enum.at(get_toasting_index())
end
