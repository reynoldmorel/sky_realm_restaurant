defmodule SkyRealmRestaurant.Services.InMemoryStore.UserRoleService do
  alias SkyRealmRestaurant.Entities.UserRole
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @user_roles_file "in_memory_store/user_roles.txt"

  defp read_user_roles_file(),
    do: FileUtils.read_entities_from_file(@user_roles_file, UserRole)

  defp write_user_roles_file_content(content),
    do: FileUtils.write_entities_to_file(@user_roles_file, content)

  def find_by_id(id) do
    {:ok, current_user_roles} = read_user_roles_file()

    {:ok,
     current_user_roles |> Enum.find(fn %UserRole{id: user_role_id} -> user_role_id == id end)}
  end

  def find_all(), do: read_user_roles_file()

  def find_by_id_enabled(id) do
    {:ok, current_user_roles} = read_user_roles_file()

    {:ok,
     current_user_roles
     |> Enum.find(fn %UserRole{id: user_role_id, status: status} ->
       user_role_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_user_roles} = read_user_roles_file()

    {:ok,
     current_user_roles
     |> Enum.filter(fn %UserRole{status: status} -> status == Status.enable() end)}
  end

  def create(new_user_role = %UserRole{}) do
    {:ok, current_user_roles} = read_user_roles_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    user_role_id = GeneralUtils.generate_id("#{length(current_user_roles)}")

    new_user_role = %UserRole{
      new_user_role
      | id: user_role_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_user_roles = [
      new_user_role | current_user_roles
    ]

    case write_user_roles_file_content(updated_current_user_roles) do
      :ok -> {:ok, new_user_role}
      error -> error
    end
  end

  def update(id, updated_user_role = %UserRole{}) do
    {:ok, current_user_roles} = read_user_roles_file()

    existing_user_role =
      Enum.find(current_user_roles, fn %UserRole{
                                         id: user_role_id
                                       } ->
        user_role_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_user_role = %UserRole{
      existing_user_role
      | user_id:
          Map.get(
            updated_user_role,
            :user_id,
            existing_user_role.user_id
          ),
        role_id:
          Map.get(
            updated_user_role,
            :role_id,
            existing_user_role.role_id
          ),
        updated_at: current_date_unix
    }

    user_role_update_mapper = fn user_role ->
      case user_role.id == id do
        true ->
          updated_user_role

        false ->
          user_role
      end
    end

    updated_current_user_roles = current_user_roles |> Enum.map(user_role_update_mapper)

    case write_user_roles_file_content(updated_current_user_roles) do
      :ok -> {:ok, updated_user_role}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_user_roles} = read_user_roles_file()

    updated_current_user_roles =
      current_user_roles
      |> Enum.filter(fn user_role -> user_role.id != id end)

    case write_user_roles_file_content(updated_current_user_roles) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
