defmodule SkyRealmRestaurant.Entities.Inventory do
  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             name: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
