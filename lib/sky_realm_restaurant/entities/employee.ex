defmodule SkyRealmRestaurant.Entities.Employee do
  alias SkyRealmRestaurant.Entities.User

  @attrs User.get_attrs() ++
           [
             employee_code: nil,
             employee_type: nil
           ]

  def get_attrs, do: @attrs

  def get_attrs_excluding(excludes \\ []), do: @attrs -- excludes
end
