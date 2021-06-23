defmodule SkyRealmRestaurant.Services.InMemoryStore.CashierService do
  alias SkyRealmRestaurant.Entities.Cashier
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  @cashiers_file "in_memory_store/cashiers.txt"

  defp read_cashiers_file(), do: FileUtils.read_entities_from_file(@cashiers_file, Cashier)

  defp write_cashiers_file_content(content),
    do: FileUtils.write_entities_to_file(@cashiers_file, content)

  def find_by_id(id),
    do: {:ok, Enum.find(read_cashiers_file(), fn %Cashier{id: cashierId} -> cashierId == id end)}

  def find_all(), do: {:ok, read_cashiers_file()}

  def create(new_cashier = %Cashier{}) do
    {:ok, current_cashiers} = read_cashiers_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    cashier_id = GeneralUtils.generate_id("#{length(current_cashiers)}")

    new_cashier = %Cashier{
      new_cashier
      | id: cashier_id,
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_cashiers = [new_cashier | current_cashiers]

    case write_cashiers_file_content(updated_current_cashiers) do
      :ok -> {:ok, new_cashier}
      error -> error
    end
  end

  def update(id, updated_cashier = %Cashier{}) do
    {:ok, current_cashiers} = read_cashiers_file()

    existing_cashier =
      Enum.find(current_cashiers, fn %Cashier{id: cashierId} -> cashierId == id end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_cashier = %Cashier{
      existing_cashier
      | document_id: Map.get(updated_cashier, :document_id, existing_cashier.document_id),
        name: Map.get(updated_cashier, :name, existing_cashier.name),
        last_name: Map.get(updated_cashier, :last_name, existing_cashier.last_name),
        age: Map.get(updated_cashier, :age, existing_cashier.age),
        employee_code: Map.get(updated_cashier, :employee_code, existing_cashier.employee_code),
        username: Map.get(updated_cashier, :username, existing_cashier.username),
        password: Map.get(updated_cashier, :password, existing_cashier.password),
        updated_at: current_date_unix
    }

    cashier_update_mapper = fn cashier ->
      case cashier.id == id do
        true ->
          updated_cashier

        false ->
          cashier
      end
    end

    updated_current_cashiers = current_cashiers |> Enum.map(cashier_update_mapper)

    case write_cashiers_file_content(updated_current_cashiers) do
      :ok -> {:ok, updated_cashier}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_cashiers} = read_cashiers_file()

    updated_current_cashiers = current_cashiers |> Enum.filter(fn cashier -> cashier.id != id end)

    case write_cashiers_file_content(updated_current_cashiers) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
