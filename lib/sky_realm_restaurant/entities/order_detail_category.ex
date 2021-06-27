defmodule SkyRealmRestaurant.Entities.OrderDetailCategory do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             order_detail_id: nil,
             category_id: nil,
             category_name: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
