defmodule SkyRealmRestaurant.Entities.User do
  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             document_id: nil,
             name: nil,
             last_name: nil,
             age: nil,
             username: nil,
             password: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
