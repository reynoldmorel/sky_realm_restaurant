defmodule SkyRealmRestaurant.Entities.Tax do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             name: nil,
             tax_value: nil,
             tax_percentage: nil,
             is_order: nil,
             is_product: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
