defmodule SkyRealmRestaurant.Entities.ProductCategory do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             product_id: nil,
             category_id: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
