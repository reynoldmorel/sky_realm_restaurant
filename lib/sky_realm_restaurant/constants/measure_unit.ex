defmodule SkyRealmRestaurant.Constants.MeasureUnit do
  @values [
    %{name: "package", units: 10},
    %{name: "unit", units: 1},
    %{name: "liter", units: 0.5},
    %{name: "cup", units: 0.3},
    %{name: "slice", units: 0.5}
  ]

  @attrs name: nil, units: nil

  defstruct @attrs

  def get_attrs, do: @attrs

  def get_values, do: @values

  def get_package_index, do: 0

  def get_unit_index, do: 1

  def get_liter_index, do: 2

  def get_cup_index, do: 3

  def get_slice_index, do: 4

  def package, do: get_values() |> Enum.at(get_package_index())

  def unit, do: get_values() |> Enum.at(get_unit_index())

  def liter, do: get_values() |> Enum.at(get_liter_index())

  def cup, do: get_values() |> Enum.at(get_cup_index())

  def slice, do: get_values() |> Enum.at(get_slice_index())
end
