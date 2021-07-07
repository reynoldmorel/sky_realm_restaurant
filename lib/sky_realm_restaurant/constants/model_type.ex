defmodule SkyRealmRestaurant.Constants.ModelType do
  @values ["model_type_order_detail", "model_type_final_product"]

  def get_values, do: @values

  def get_order_detail_index, do: 0

  def get_final_product_index, do: 1

  def order_detail, do: get_values() |> Enum.at(get_order_detail_index())

  def final_product, do: get_values() |> Enum.at(get_final_product_index())
end
