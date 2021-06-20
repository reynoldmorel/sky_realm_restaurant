defmodule SkyRealmRestaurant.Entities.Cashier do
  alias SkyRealmRestaurant.Entities.Employee
  alias SkyRealmRestaurant.Constants.EmployeeType

  @attrs Employee.get_attrs_excluding(employee_type: nil) ++
           [
             employee_type: EmployeeType.cashier()
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
