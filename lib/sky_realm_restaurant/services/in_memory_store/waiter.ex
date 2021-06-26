defmodule SkyRealmRestaurant.Services.InMemoryStore.WaiterService do
  alias SkyRealmRestaurant.Entities.Waiter
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @waiters_file "in_memory_store/waiters.txt"

  defp read_waiters_file(), do: FileUtils.read_entities_from_file(@waiters_file, Waiter)

  defp write_waiters_file_content(content),
    do: FileUtils.write_entities_to_file(@waiters_file, content)

  def find_by_id(id) do
    {:ok, current_waiters} = read_waiters_file()

    {:ok, current_waiters |> Enum.find(fn %Waiter{id: waiter_id} -> waiter_id == id end)}
  end

  def find_all(), do: read_waiters_file()

  def find_by_id_enabled(id) do
    {:ok, current_waiters} = read_waiters_file()

    {:ok,
     current_waiters
     |> Enum.find(fn %Waiter{id: waiter_id, status: status} ->
       waiter_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_waiters} = read_waiters_file()

    {:ok,
     current_waiters
     |> Enum.filter(fn %Waiter{status: status} -> status == Status.enable() end)}
  end

  def find_by_username_enabled(username) do
    {:ok, current_waiters} = read_waiters_file()

    {:ok,
     current_waiters
     |> Enum.find(fn %Waiter{username: waiter_username, status: status} ->
       waiter_username == username and status == Status.enable()
     end)}
  end

  def create(new_waiter = %Waiter{}) do
    {:ok, current_waiters} = read_waiters_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    waiter_id = GeneralUtils.generate_id("#{length(current_waiters)}")

    new_waiter = %Waiter{
      new_waiter
      | id: waiter_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_waiters = [new_waiter | current_waiters]

    case write_waiters_file_content(updated_current_waiters) do
      :ok -> {:ok, new_waiter}
      error -> error
    end
  end

  def update(id, updated_waiter = %Waiter{}) do
    {:ok, current_waiters} = read_waiters_file()
    existing_waiter = Enum.find(current_waiters, fn %Waiter{id: waiter_id} -> waiter_id == id end)
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_waiter = %Waiter{
      existing_waiter
      | document_id: Map.get(updated_waiter, :document_id, existing_waiter.document_id),
        name: Map.get(updated_waiter, :name, existing_waiter.name),
        last_name: Map.get(updated_waiter, :last_name, existing_waiter.last_name),
        age: Map.get(updated_waiter, :age, existing_waiter.age),
        employee_code: Map.get(updated_waiter, :employee_code, existing_waiter.employee_code),
        username: Map.get(updated_waiter, :username, existing_waiter.username),
        password: Map.get(updated_waiter, :password, existing_waiter.password),
        updated_at: current_date_unix
    }

    waiter_update_mapper = fn waiter ->
      case waiter.id == id do
        true ->
          updated_waiter

        false ->
          waiter
      end
    end

    updated_current_waiters = current_waiters |> Enum.map(waiter_update_mapper)

    case write_waiters_file_content(updated_current_waiters) do
      :ok -> {:ok, updated_waiter}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_waiters} = read_waiters_file()

    updated_current_waiters = current_waiters |> Enum.filter(fn waiter -> waiter.id != id end)

    case write_waiters_file_content(updated_current_waiters) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
