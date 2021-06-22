defmodule SkyRealmRestaurant.Constants.ModelType do
  @values ["order_detail"]

  def get_values, do: @values

  def get_order_detail_index, do: 0

  def order_detail, do: get_values() |> Enum.at(get_order_detail_index())
end
