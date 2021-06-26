defmodule SkyRealmRestaurant.Services.InMemoryStore.EmployeeService do
  alias SkyRealmRestaurant.Entities.Employee
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @employees_file "in_memory_store/employees.txt"

  defp read_employees_file(), do: FileUtils.read_entities_from_file(@employees_file, Employee)

  defp write_employees_file_content(content),
    do: FileUtils.write_entities_to_file(@employees_file, content)

  def find_by_id(id) do
    {:ok, current_employees} = read_employees_file()

    {:ok, current_employees |> Enum.find(fn %Employee{id: employee_id} -> employee_id == id end)}
  end

  def find_all(), do: read_employees_file()

  def find_by_id_enabled(id) do
    {:ok, current_employees} = read_employees_file()

    {:ok,
     current_employees
     |> Enum.find(fn %Employee{id: employee_id, status: status} ->
       employee_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_employees} = read_employees_file()

    {:ok,
     current_employees
     |> Enum.filter(fn %Employee{status: status} -> status == Status.enable() end)}
  end

  def find_by_username_enabled(username) do
    {:ok, current_employees} = read_employees_file()

    {:ok,
     current_employees
     |> Enum.find(fn %Employee{username: employee_username, status: status} ->
       employee_username == username and status == Status.enable()
     end)}
  end

  def create(new_employee = %Employee{}) do
    {:ok, current_employees} = read_employees_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    employee_id = GeneralUtils.generate_id("#{length(current_employees)}")

    new_employee = %Employee{
      new_employee
      | id: employee_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_employees = [new_employee | current_employees]

    case write_employees_file_content(updated_current_employees) do
      :ok -> {:ok, new_employee}
      error -> error
    end
  end

  def update(id, updated_employee = %Employee{}) do
    {:ok, current_employees} = read_employees_file()

    existing_employee =
      Enum.find(current_employees, fn %Employee{id: employee_id} -> employee_id == id end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_employee = %Employee{
      existing_employee
      | employee_type: Map.get(updated_employee, :employee_type, existing_employee.employee_type),
        document_id: Map.get(updated_employee, :document_id, existing_employee.document_id),
        name: Map.get(updated_employee, :name, existing_employee.name),
        last_name: Map.get(updated_employee, :last_name, existing_employee.last_name),
        age: Map.get(updated_employee, :age, existing_employee.age),
        employee_code: Map.get(updated_employee, :employee_code, existing_employee.employee_code),
        username: Map.get(updated_employee, :username, existing_employee.username),
        password: Map.get(updated_employee, :password, existing_employee.password),
        updated_at: current_date_unix
    }

    employee_update_mapper = fn employee ->
      case employee.id == id do
        true ->
          updated_employee

        false ->
          employee
      end
    end

    updated_current_employees = current_employees |> Enum.map(employee_update_mapper)

    case write_employees_file_content(updated_current_employees) do
      :ok -> {:ok, updated_employee}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_employees} = read_employees_file()

    updated_current_employees =
      current_employees |> Enum.filter(fn employee -> employee.id != id end)

    case write_employees_file_content(updated_current_employees) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
