defmodule SkyRealmRestaurant.Entities.Waiter do
  alias SkyRealmRestaurant.Entities.Employee
  alias SkyRealmRestaurant.Constants.EmployeeType

  @attrs Employee.get_attrs_excluding(employee_type: nil) ++
           [
             employee_type: EmployeeType.waiter()
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
