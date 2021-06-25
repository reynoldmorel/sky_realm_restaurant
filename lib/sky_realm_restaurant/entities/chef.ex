defmodule SkyRealmRestaurant.Entities.Chef do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.Employee
  alias SkyRealmRestaurant.Constants.EmployeeType

  @attrs Employee.get_attrs_excluding(employee_type: nil) ++
           [
             employee_type: EmployeeType.chef(),
             experience_level: nil,
             working_status: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
