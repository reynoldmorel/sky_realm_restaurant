defmodule SkyRealmRestaurant.Entities.OrderDetail do
  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             order_id: nil,
             product_id: nil,
             produt_name: nil,
             produt_serial: nil,
             difficulty_level: nil,
             category_id: nil,
             quantity: nil,
             price: nil,
             tax_total: nil,
             cooking_status: nil,
             preparation_status: nil,
             processing_status: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
