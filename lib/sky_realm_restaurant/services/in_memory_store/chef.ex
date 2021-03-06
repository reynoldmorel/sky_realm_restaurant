defmodule SkyRealmRestaurant.Services.InMemoryStore.ChefService do
  alias SkyRealmRestaurant.Entities.Chef
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status
  alias SkyRealmRestaurant.Constants.ChefWorkingStatus

  @chefs_file "in_memory_store/chefs.txt"

  defp read_chefs_file(), do: FileUtils.read_entities_from_file(@chefs_file, Chef)

  defp write_chefs_file_content(content),
    do: FileUtils.write_entities_to_file(@chefs_file, content)

  def find_by_id(id) do
    {:ok, current_chefs} = read_chefs_file()

    {:ok, current_chefs |> Enum.find(fn %Chef{id: chef_id} -> chef_id == id end)}
  end

  def find_all(), do: read_chefs_file()

  def find_by_id_enabled(id) do
    {:ok, current_chefs} = read_chefs_file()

    {:ok,
     current_chefs
     |> Enum.find(fn %Chef{id: chef_id, status: status} ->
       chef_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_chefs} = read_chefs_file()

    {:ok,
     current_chefs
     |> Enum.filter(fn %Chef{status: status} -> status == Status.enable() end)}
  end

  def find_by_username_enabled(username) do
    {:ok, current_chefs} = read_chefs_file()

    {:ok,
     current_chefs
     |> Enum.find(fn %Chef{username: chef_username, status: status} ->
       chef_username == username and status == Status.enable()
     end)}
  end

  def find_all_available() do
    {:ok, current_chefs} = read_chefs_file()

    {:ok,
     current_chefs
     |> Enum.filter(fn %Chef{working_status: chef_working_status, status: status} ->
       (chef_working_status == nil or chef_working_status == ChefWorkingStatus.idle()) and
         status == Status.enable()
     end)}
  end

  def create(new_chef = %Chef{}) do
    {:ok, current_chefs} = read_chefs_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    chef_id = GeneralUtils.generate_id("#{length(current_chefs)}")

    new_chef = %Chef{
      new_chef
      | id: chef_id,
        working_status: ChefWorkingStatus.idle(),
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_chefs = [new_chef | current_chefs]

    case write_chefs_file_content(updated_current_chefs) do
      :ok -> {:ok, new_chef}
      error -> error
    end
  end

  def update(id, updated_chef = %Chef{}) do
    {:ok, current_chefs} = read_chefs_file()
    existing_chef = Enum.find(current_chefs, fn %Chef{id: chef_id} -> chef_id == id end)
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_chef = %Chef{
      existing_chef
      | document_id: Map.get(updated_chef, :document_id, existing_chef.document_id),
        name: Map.get(updated_chef, :name, existing_chef.name),
        last_name: Map.get(updated_chef, :last_name, existing_chef.last_name),
        age: Map.get(updated_chef, :age, existing_chef.age),
        employee_code: Map.get(updated_chef, :employee_code, existing_chef.employee_code),
        experience_level:
          Map.get(updated_chef, :experience_level, existing_chef.experience_level),
        username: Map.get(updated_chef, :username, existing_chef.username),
        password: Map.get(updated_chef, :password, existing_chef.password),
        working_status: Map.get(updated_chef, :working_status, existing_chef.working_status),
        updated_at: current_date_unix
    }

    chef_update_mapper = fn chef ->
      case chef.id == id do
        true ->
          updated_chef

        false ->
          chef
      end
    end

    updated_current_chefs = current_chefs |> Enum.map(chef_update_mapper)

    case write_chefs_file_content(updated_current_chefs) do
      :ok -> {:ok, updated_chef}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_chefs} = read_chefs_file()

    updated_current_chefs = current_chefs |> Enum.filter(fn chef -> chef.id != id end)

    case write_chefs_file_content(updated_current_chefs) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
