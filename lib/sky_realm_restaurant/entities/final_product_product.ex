defmodule SkyRealmRestaurant.Entities.FinalProductProduct do
  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             product_id: nil,
             final_product_id: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
