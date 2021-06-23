defmodule SkyRealmRestaurant.Services.InMemoryStore.RoleService do
  alias SkyRealmRestaurant.Entities.Role
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  @roles_file "in_memory_store/roles.txt"

  defp read_roles_file(), do: FileUtils.read_entities_from_file(@roles_file, Role)

  defp write_roles_file_content(content),
    do: FileUtils.write_entities_to_file(@roles_file, content)

  def find_by_id(id),
    do: {:ok, Enum.find(read_roles_file(), fn %Role{id: role_id} -> role_id == id end)}

  def find_all(), do: {:ok, read_roles_file()}

  def create(new_role = %Role{}) do
    {:ok, current_roles} = read_roles_file()

    role_id = GeneralUtils.generate_id("#{length(current_roles)}")

    new_role = %Role{
      new_role
      | id: role_id
    }

    updated_current_roles = [new_role | current_roles]

    case write_roles_file_content(updated_current_roles) do
      :ok -> {:ok, new_role}
      error -> error
    end
  end

  def update(id, updated_role = %Role{}) do
    {:ok, current_roles} = read_roles_file()

    existing_role = Enum.find(current_roles, fn %Role{id: role_id} -> role_id == id end)

    updated_role = %Role{
      existing_role
      | display_name: Map.get(updated_role, :display_name, existing_role.display_name),
        name: Map.get(updated_role, :name, existing_role.name)
    }

    role_update_mapper = fn role ->
      case role.id == id do
        true ->
          updated_role

        false ->
          role
      end
    end

    updated_current_roles = current_roles |> Enum.map(role_update_mapper)

    case write_roles_file_content(updated_current_roles) do
      :ok -> {:ok, updated_role}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_roles} = read_roles_file()

    updated_current_roles = current_roles |> Enum.filter(fn role -> role.id != id end)

    case write_roles_file_content(updated_current_roles) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
