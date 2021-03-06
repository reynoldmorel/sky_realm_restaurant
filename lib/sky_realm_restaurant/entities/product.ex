defmodule SkyRealmRestaurant.Entities.Product do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             parent_product_id: nil,
             serial: nil,
             name: nil,
             display_name: nil,
             price: 0.0,
             supported_measure_units: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
