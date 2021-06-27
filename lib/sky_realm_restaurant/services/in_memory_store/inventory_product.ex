defmodule SkyRealmRestaurant.Services.InMemoryStore.InventoryProductService do
  alias SkyRealmRestaurant.Entities.InventoryProduct
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @inventory_products_file "in_memory_store/inventory_products.txt"

  defp read_inventory_products_file(),
    do: FileUtils.read_entities_from_file(@inventory_products_file, InventoryProduct)

  defp write_inventory_products_file_content(content),
    do: FileUtils.write_entities_to_file(@inventory_products_file, content)

  def find_by_id(id) do
    {:ok, current_inventory_products} = read_inventory_products_file()

    {:ok,
     current_inventory_products
     |> Enum.find(fn %InventoryProduct{id: inventory_product_id} ->
       inventory_product_id == id
     end)}
  end

  def find_all(), do: read_inventory_products_file()

  def find_by_id_enabled(id) do
    {:ok, current_inventory_products} = read_inventory_products_file()

    {:ok,
     current_inventory_products
     |> Enum.find(fn %InventoryProduct{id: inventory_product_id, status: status} ->
       inventory_product_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_inventory_products} = read_inventory_products_file()

    {:ok,
     current_inventory_products
     |> Enum.filter(fn %InventoryProduct{status: status} -> status == Status.enable() end)}
  end

  def find_all_by_inventory_id_enabled(inventory_id) do
    {:ok, current_inventory_products} = read_inventory_products_file()

    {:ok,
     current_inventory_products
     |> Enum.filter(fn %InventoryProduct{
                         inventory_id: inventory_product_inventory_id,
                         status: status
                       } ->
       inventory_product_inventory_id == inventory_id and status == Status.enable()
     end)}
  end

  def find_all_by_product_id_enabled(product_id) do
    {:ok, current_inventory_products} = read_inventory_products_file()

    {:ok,
     current_inventory_products
     |> Enum.filter(fn %InventoryProduct{
                         product_id: inventory_product_product_id,
                         status: status
                       } ->
       inventory_product_product_id == product_id and status == Status.enable()
     end)}
  end

  def find_by_inventory_id_and_product_id_enabled(inventory_id, product_id) do
    {:ok, current_inventory_products} = read_inventory_products_file()

    {:ok,
     current_inventory_products
     |> Enum.filter(fn %InventoryProduct{
                         inventory_id: inventory_product_inventory_id,
                         product_id: inventory_product_product_id,
                         status: status
                       } ->
       inventory_product_inventory_id == inventory_id and
         inventory_product_product_id == product_id and status == Status.enable()
     end)}
  end

  def create(new_inventory_product = %InventoryProduct{}) do
    {:ok, current_inventory_products} = read_inventory_products_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    inventory_product_id = GeneralUtils.generate_id("#{length(current_inventory_products)}")

    new_inventory_product = %InventoryProduct{
      new_inventory_product
      | id: inventory_product_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_inventory_products = [
      new_inventory_product | current_inventory_products
    ]

    case write_inventory_products_file_content(updated_current_inventory_products) do
      :ok -> {:ok, new_inventory_product}
      error -> error
    end
  end

  def update(id, updated_inventory_product = %InventoryProduct{}) do
    {:ok, current_inventory_products} = read_inventory_products_file()

    existing_inventory_product =
      Enum.find(current_inventory_products, fn %InventoryProduct{
                                                 id: inventory_product_id
                                               } ->
        inventory_product_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_inventory_product = %InventoryProduct{
      existing_inventory_product
      | inventory_id:
          Map.get(
            updated_inventory_product,
            :inventory_id,
            existing_inventory_product.inventory_id
          ),
        product_id:
          Map.get(
            updated_inventory_product,
            :product_id,
            existing_inventory_product.product_id
          ),
        quantity:
          Map.get(
            updated_inventory_product,
            :quantity,
            existing_inventory_product.quantity
          ),
        measure_unit:
          Map.get(
            updated_inventory_product,
            :measure_unit,
            existing_inventory_product.measure_unit
          ),
        updated_at: current_date_unix
    }

    inventory_product_update_mapper = fn inventory_product ->
      case inventory_product.id == id do
        true ->
          updated_inventory_product

        false ->
          inventory_product
      end
    end

    updated_current_inventory_products =
      current_inventory_products |> Enum.map(inventory_product_update_mapper)

    case write_inventory_products_file_content(updated_current_inventory_products) do
      :ok -> {:ok, updated_inventory_product}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_inventory_products} = read_inventory_products_file()

    updated_current_inventory_products =
      current_inventory_products
      |> Enum.filter(fn inventory_product -> inventory_product.id != id end)

    case write_inventory_products_file_content(updated_current_inventory_products) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
