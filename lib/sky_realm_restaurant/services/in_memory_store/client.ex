defmodule SkyRealmRestaurant.Services.InMemoryStore.ClientService do
  alias SkyRealmRestaurant.Entities.Client
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  @clients_file "in_memory_store/clients.txt"

  defp read_clients_file(), do: FileUtils.read_entities_from_file(@clients_file, Client)

  defp write_clients_file_content(content),
    do: FileUtils.write_entities_to_file(@clients_file, content)

  def find_by_id(id),
    do: {:ok, Enum.find(read_clients_file(), fn %Client{id: client_id} -> client_id == id end)}

  def find_all(), do: {:ok, read_clients_file()}

  def create(new_client = %Client{}) do
    {:ok, current_clients} = read_clients_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    client_id = GeneralUtils.generate_id("#{length(current_clients)}")

    new_client = %Client{
      new_client
      | id: client_id,
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_clients = [new_client | current_clients]

    case write_clients_file_content(updated_current_clients) do
      :ok -> {:ok, new_client}
      error -> error
    end
  end

  def update(id, updated_client = %Client{}) do
    {:ok, current_clients} = read_clients_file()
    existing_client = Enum.find(current_clients, fn %Client{id: client_id} -> client_id == id end)
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_client = %Client{
      existing_client
      | document_id: Map.get(updated_client, :document_id, existing_client.document_id),
        name: Map.get(updated_client, :name, existing_client.name),
        last_name: Map.get(updated_client, :last_name, existing_client.last_name),
        age: Map.get(updated_client, :age, existing_client.age),
        client_code: Map.get(updated_client, :client_code, existing_client.client_code),
        username: Map.get(updated_client, :username, existing_client.username),
        password: Map.get(updated_client, :password, existing_client.password),
        updated_at: current_date_unix
    }

    client_update_mapper = fn client ->
      case client.id == id do
        true ->
          updated_client

        false ->
          client
      end
    end

    updated_current_clients = current_clients |> Enum.map(client_update_mapper)

    case write_clients_file_content(updated_current_clients) do
      :ok -> {:ok, updated_client}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_clients} = read_clients_file()

    updated_current_clients = current_clients |> Enum.filter(fn client -> client.id != id end)

    case write_clients_file_content(updated_current_clients) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
