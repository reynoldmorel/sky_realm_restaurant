defmodule SkyRealmRestaurant.Controllers.EmployeeController do
  alias SkyRealmRestaurant.Entities.Employee
  alias SkyRealmRestaurant.Services.InMemoryStore.EmployeeService

  def find_by_id(id), do: EmployeeService.find_by_id(id)

  def find_all(), do: EmployeeService.find_all()

  def find_by_id_enabled(id), do: EmployeeService.find_by_id_enabled(id)

  def find_all_enabled(), do: EmployeeService.find_all_enabled()

  def create(new_employee = %Employee{}), do: EmployeeService.create(new_employee)

  def update(id, updated_employee = %Employee{}), do: EmployeeService.update(id, updated_employee)

  def delete(id), do: EmployeeService.delete(id)
end
