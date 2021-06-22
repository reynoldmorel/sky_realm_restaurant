defmodule SkyRealmRestaurant.Services.InMemoryStore.UserService do
  alias SkyRealmRestaurant.Entities.User
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  @users_file "in_memory_store/users.txt"

  defp read_users_file(), do: FileUtils.read_entities_from_file(@users_file, User)

  defp write_users_file_content(content),
    do: FileUtils.write_entities_to_file(@users_file, content)

  def find_by_id(id),
    do: {:ok, Enum.find(read_users_file(), fn %User{id: userId} -> userId == id end)}

  def find_all(), do: {:ok, read_users_file()}

  def create(new_user = %User{}) do
    {:ok, current_users} = read_users_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    user_id = GeneralUtils.generate_id("#{length(current_users)}")

    new_user = %User{
      new_user
      | id: user_id,
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_users = [new_user | current_users]

    case write_users_file_content(updated_current_users) do
      :ok -> {:ok, new_user}
      error -> error
    end
  end

  def update(id, updated_user = %User{}) do
    {:ok, current_users} = read_users_file()
    existing_user = Enum.find(current_users, fn %User{id: userId} -> userId == id end)
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_user = %User{
      existing_user
      | document_id: Map.get(updated_user, :document_id, existing_user.document_id),
        name: Map.get(updated_user, :name, existing_user.name),
        last_name: Map.get(updated_user, :last_name, existing_user.last_name),
        age: Map.get(updated_user, :age, existing_user.age),
        username: Map.get(updated_user, :username, existing_user.username),
        password: Map.get(updated_user, :password, existing_user.password),
        updated_at: current_date_unix
    }

    user_update_mapper = fn user ->
      case user.id == id do
        true ->
          updated_user

        false ->
          user
      end
    end

    updated_current_users = current_users |> Enum.map(user_update_mapper)

    case write_users_file_content(updated_current_users) do
      :ok -> {:ok, updated_user}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_users} = read_users_file()

    updated_current_users = current_users |> Enum.filter(fn user -> user.id != id end)

    case write_users_file_content(updated_current_users) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
