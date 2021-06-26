defmodule SkyRealmRestaurant.Services.InMemoryStore.InventoryService do
  alias SkyRealmRestaurant.Entities.Inventory
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @inventories_file "in_memory_store/inventories.txt"

  defp read_inventories_file(),
    do: FileUtils.read_entities_from_file(@inventories_file, Inventory)

  defp write_inventories_file_content(content),
    do: FileUtils.write_entities_to_file(@inventories_file, content)

  def find_by_id(id),
    do:
      {:ok,
       Enum.find(read_inventories_file(), fn %Inventory{id: inventory_id} ->
         inventory_id == id
       end)}

  def find_all(), do: {:ok, read_inventories_file()}

  def find_by_id_enabled(id),
    do:
      {:ok,
       read_inventories_file()
       |> Enum.find(fn %Inventory{id: inventory_id, status: status} ->
         inventory_id == id and status == Status.enable()
       end)}

  def find_all_enabled(),
    do:
      {:ok,
       read_inventories_file()
       |> Enum.filter(fn %Inventory{status: status} -> status == Status.enable() end)}

  def create(new_inventory = %Inventory{}) do
    {:ok, current_inventories} = read_inventories_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    inventory_id = GeneralUtils.generate_id("#{length(current_inventories)}")

    new_inventory = %Inventory{
      new_inventory
      | id: inventory_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_inventories = [new_inventory | current_inventories]

    case write_inventories_file_content(updated_current_inventories) do
      :ok -> {:ok, new_inventory}
      error -> error
    end
  end

  def update(id, updated_inventory = %Inventory{}) do
    {:ok, current_inventories} = read_inventories_file()

    existing_inventory =
      Enum.find(current_inventories, fn %Inventory{id: inventory_id} -> inventory_id == id end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_inventory = %Inventory{
      existing_inventory
      | name: Map.get(updated_inventory, :name, existing_inventory.name),
        updated_at: current_date_unix
    }

    inventory_update_mapper = fn inventory ->
      case inventory.id == id do
        true ->
          updated_inventory

        false ->
          inventory
      end
    end

    updated_current_inventories = current_inventories |> Enum.map(inventory_update_mapper)

    case write_inventories_file_content(updated_current_inventories) do
      :ok -> {:ok, updated_inventory}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_inventories} = read_inventories_file()

    updated_current_inventories =
      current_inventories |> Enum.filter(fn inventory -> inventory.id != id end)

    case write_inventories_file_content(updated_current_inventories) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
