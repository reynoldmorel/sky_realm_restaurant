defmodule SkyRealmRestaurant.Entities.OrderDetail do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             order_id: nil,
             quantity: 0,
             price: 0.0,
             tax_total: 0.0,
             cooking_status: nil,
             preparation_status: nil,
             processing_status: nil,
             product: nil,
             taxes: nil,
             categories: nil,
             selected_measure_unit: nil,
             inventory: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
