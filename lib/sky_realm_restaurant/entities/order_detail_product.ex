defmodule SkyRealmRestaurant.Entities.OrderDetailProduct do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             order_detail_id: nil,
             product_id: nil,
             produt_name: nil,
             produt_display_name: nil,
             produt_serial: nil,
             difficulty_level: nil,
             is_final_product: nil,
             measure_unit: nil,
             inventory_id: nil,
             cooking_steps: []
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
