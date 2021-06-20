defmodule SkyRealmRestaurant.Entities.Product do
  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             parent_product_id: nil,
             serial: nil,
             name: nil,
             display_name: nil,
             price: nil,
             supported_measure_units: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
