defmodule SkyRealmRestaurant.Constants.EmployeeType do
  @values ["chef", "cashier", "waiter"]

  def get_values, do: @values

  def get_chef_index, do: 0

  def get_cashier_index, do: 1

  def get_waiter_index, do: 2

  def chef, do: get_values() |> Enum.at(get_chef_index())

  def cashier, do: get_values() |> Enum.at(get_cashier_index())

  def waiter, do: get_values() |> Enum.at(get_waiter_index())
end
