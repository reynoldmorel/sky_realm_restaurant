defmodule SkyRealmRestaurant.Entities.Client do
  alias SkyRealmRestaurant.Entities.User

  @attrs User.get_attrs() ++
           [
             client_code: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
