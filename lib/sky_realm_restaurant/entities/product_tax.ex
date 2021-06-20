defmodule SkyRealmRestaurant.Entities.ProductTax do
  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             tax_id: nil,
             product_id: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
