defmodule SkyRealmRestaurant.Entities.UserRole do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             user_id: nil,
             role_id: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
