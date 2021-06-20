defmodule SkyRealmRestaurant.Entities.BaseAttrs do
  @attrs [created_at: nil, updated_at: nil, created_by: nil, updated_by: nil, status: nil]

  def get_attrs, do: @attrs
end
