defmodule SkyRealmRestaurant.Constants.CookingStatus do
  @values [
    %{name: "frying", default_timeout_ms: 2000},
    %{name: "boiling", default_timeout_ms: 3000},
    %{name: "baking", default_timeout_ms: 4000},
    %{name: "toasting", default_timeout_ms: 5000},
    %{name: "heating_oven", default_timeout_ms: 6000},
    %{name: "prepare_juice", default_timeout_ms: 1000}
  ]

  def get_values, do: @values

  def get_frying_index, do: 0

  def get_boiling_index, do: 1

  def get_baking_index, do: 2

  def get_toasting_index, do: 3

  def get_heating_oven_index, do: 4

  def get_prepare_juice_index, do: 5

  def frying, do: get_values() |> Enum.at(get_frying_index())

  def boiling, do: get_values() |> Enum.at(get_boiling_index())

  def baking, do: get_values() |> Enum.at(get_baking_index())

  def toasting, do: get_values() |> Enum.at(get_toasting_index())

  def heating_oven, do: get_values() |> Enum.at(get_heating_oven_index())

  def prepare_juice, do: get_values() |> Enum.at(get_prepare_juice_index())

  def get_cooking_steps(opt) do
    case opt do
      0 -> [heating_oven(), boiling(), baking(), toasting()]
      1 -> [heating_oven(), frying()]
      2 -> [baking()]
      3 -> [baking(), boiling()]
      4 -> [heating_oven(), boiling(), toasting()]
      5 -> [prepare_juice()]
    end
  end
end
