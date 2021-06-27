defmodule SkyRealmRestaurant.Entities.OrderTax do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             order_id: nil,
             tax_id: nil,
             tax_name: nil,
             tax_value: nil,
             tax_percentage: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
