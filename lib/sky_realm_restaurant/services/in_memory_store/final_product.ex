defmodule SkyRealmRestaurant.Services.InMemoryStore.FinalProductService do
  alias SkyRealmRestaurant.Entities.FinalProduct
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @final_products_file "in_memory_store/final_products.txt"

  defp read_final_products_file(),
    do: FileUtils.read_entities_from_file(@final_products_file, FinalProduct)

  defp write_final_products_file_content(content),
    do: FileUtils.write_entities_to_file(@final_products_file, content)

  def find_by_id(id),
    do:
      {:ok,
       Enum.find(read_final_products_file(), fn %FinalProduct{id: final_product_id} ->
         final_product_id == id
       end)}

  def find_all(), do: {:ok, read_final_products_file()}

  def find_by_id_enabled(id),
    do:
      {:ok,
       read_final_products_file()
       |> Enum.find(fn %FinalProduct{id: final_product_id, status: status} ->
         final_product_id == id and status == Status.enable()
       end)}

  def find_all_enabled(),
    do:
      {:ok,
       read_final_products_file()
       |> Enum.filter(fn %FinalProduct{status: status} -> status == Status.enable() end)}

  def find_by_serial_enabled(serial),
    do:
      {:ok,
       read_final_products_file()
       |> Enum.find(fn %FinalProduct{serial: final_product_serial, status: status} ->
         final_product_serial == serial and status == Status.enable()
       end)}

  def create(new_final_product = %FinalProduct{}) do
    {:ok, current_final_products} = read_final_products_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    final_product_id = GeneralUtils.generate_id("#{length(current_final_products)}")

    new_final_product = %FinalProduct{
      new_final_product
      | id: final_product_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_final_products = [new_final_product | current_final_products]

    case write_final_products_file_content(updated_current_final_products) do
      :ok -> {:ok, new_final_product}
      error -> error
    end
  end

  def update(id, updated_final_product = %FinalProduct{}) do
    {:ok, current_final_products} = read_final_products_file()

    existing_final_product =
      Enum.find(current_final_products, fn %FinalProduct{id: final_product_id} ->
        final_product_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_final_product = %FinalProduct{
      existing_final_product
      | cooking_steps:
          Map.get(
            updated_final_product,
            :cooking_steps,
            existing_final_product.cooking_steps
          ),
        difficulty_level:
          Map.get(
            updated_final_product,
            :difficulty_level,
            existing_final_product.difficulty_level
          ),
        parent_product_id:
          Map.get(
            updated_final_product,
            :parent_product_id,
            existing_final_product.parent_product_id
          ),
        serial: Map.get(updated_final_product, :serial, existing_final_product.serial),
        name: Map.get(updated_final_product, :name, existing_final_product.name),
        display_name:
          Map.get(updated_final_product, :display_name, existing_final_product.display_name),
        price: Map.get(updated_final_product, :price, existing_final_product.price),
        supported_measure_units:
          Map.get(
            updated_final_product,
            :supported_measure_units,
            existing_final_product.supported_measure_units
          ),
        updated_at: current_date_unix
    }

    final_product_update_mapper = fn final_product ->
      case final_product.id == id do
        true ->
          updated_final_product

        false ->
          final_product
      end
    end

    updated_current_final_products =
      current_final_products |> Enum.map(final_product_update_mapper)

    case write_final_products_file_content(updated_current_final_products) do
      :ok -> {:ok, updated_final_product}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_final_products} = read_final_products_file()

    updated_current_final_products =
      current_final_products |> Enum.filter(fn final_product -> final_product.id != id end)

    case write_final_products_file_content(updated_current_final_products) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
