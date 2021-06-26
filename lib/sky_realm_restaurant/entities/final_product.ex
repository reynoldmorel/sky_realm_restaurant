defmodule SkyRealmRestaurant.Entities.FinalProduct do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.Product

  @attrs Product.get_attrs() ++
           [
             cooking_steps: [],
             difficulty_level: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
