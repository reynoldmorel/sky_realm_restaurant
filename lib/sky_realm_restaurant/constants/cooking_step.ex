defmodule SkyRealmRestaurant.Constants.CookingStep do
  @derive Jason.Encoder

  @values [
    %{name: "cooking_step_frying", default_timeout_sec: 20},
    %{name: "cooking_step_boiling", default_timeout_sec: 30},
    %{name: "cooking_step_baking", default_timeout_sec: 40},
    %{name: "cooking_step_toasting", default_timeout_sec: 50},
    %{name: "cooking_step_heating_oven", default_timeout_sec: 60},
    %{name: "cooking_step_prepare_juice", default_timeout_sec: 10},
    %{name: "cooking_step_completed", default_timeout_sec: 0}
  ]

  @attrs name: nil, default_timeout_sec: nil

  defstruct @attrs

  def get_attrs, do: @attrs

  def get_values, do: @values

  def get_frying_index, do: 0

  def get_boiling_index, do: 1

  def get_baking_index, do: 2

  def get_toasting_index, do: 3

  def get_heating_oven_index, do: 4

  def get_prepare_juice_index, do: 5

  def get_completed_index, do: 6

  def frying, do: get_values() |> Enum.at(get_frying_index())

  def boiling, do: get_values() |> Enum.at(get_boiling_index())

  def baking, do: get_values() |> Enum.at(get_baking_index())

  def toasting, do: get_values() |> Enum.at(get_toasting_index())

  def heating_oven, do: get_values() |> Enum.at(get_heating_oven_index())

  def prepare_juice, do: get_values() |> Enum.at(get_prepare_juice_index())

  def completed, do: get_values() |> Enum.at(get_completed_index())

  def get_cooking_steps(opt) do
    case opt do
      0 -> [heating_oven(), boiling(), baking(), toasting(), completed()]
      1 -> [heating_oven(), frying(), completed()]
      2 -> [baking(), completed()]
      3 -> [baking(), boiling(), completed()]
      4 -> [heating_oven(), boiling(), toasting(), completed()]
      5 -> [prepare_juice(), completed()]
    end
  end
end
