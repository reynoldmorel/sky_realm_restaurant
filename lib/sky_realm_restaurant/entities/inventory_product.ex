defmodule SkyRealmRestaurant.Entities.InventoryProduct do
  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             inventory_id: nil,
             product_id: nil,
             quantity: nil,
             measure_unit: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
