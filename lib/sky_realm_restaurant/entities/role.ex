defmodule SkyRealmRestaurant.Entities.Role do
  @attrs [id: nil, name: nil, display_name: nil]

  defstruct @attrs

  def get_attrs, do: @attrs
end
