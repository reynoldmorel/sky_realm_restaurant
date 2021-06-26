defmodule SkyRealmRestaurant.Services.InMemoryStore.FinalProductProductService do
  alias SkyRealmRestaurant.Entities.FinalProductProduct
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @final_product_products_file "in_memory_store/final_product_products.txt"

  defp read_final_product_products_file(),
    do: FileUtils.read_entities_from_file(@final_product_products_file, FinalProductProduct)

  defp write_final_product_products_file_content(content),
    do: FileUtils.write_entities_to_file(@final_product_products_file, content)

  def find_by_id(id),
    do:
      {:ok,
       Enum.find(read_final_product_products_file(), fn %FinalProductProduct{
                                                          id: final_product_product_id
                                                        } ->
         final_product_product_id == id
       end)}

  def find_all(), do: {:ok, read_final_product_products_file()}

  def find_by_id_enabled(id),
    do:
      {:ok,
       read_final_product_products_file()
       |> Enum.find(fn %FinalProductProduct{id: final_product_product_id, status: status} ->
         final_product_product_id == id and status == Status.enable()
       end)}

  def find_all_enabled(),
    do:
      {:ok,
       read_final_product_products_file()
       |> Enum.filter(fn %FinalProductProduct{status: status} -> status == Status.enable() end)}

  def create(new_final_product_product = %FinalProductProduct{}) do
    {:ok, current_final_product_products} = read_final_product_products_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    final_product_product_id =
      GeneralUtils.generate_id("#{length(current_final_product_products)}")

    new_final_product_product = %FinalProductProduct{
      new_final_product_product
      | id: final_product_product_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_final_product_products = [
      new_final_product_product | current_final_product_products
    ]

    case write_final_product_products_file_content(updated_current_final_product_products) do
      :ok -> {:ok, new_final_product_product}
      error -> error
    end
  end

  def update(id, updated_final_product_product = %FinalProductProduct{}) do
    {:ok, current_final_product_products} = read_final_product_products_file()

    existing_final_product_product =
      Enum.find(current_final_product_products, fn %FinalProductProduct{
                                                     id: final_product_product_id
                                                   } ->
        final_product_product_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_final_product_product = %FinalProductProduct{
      existing_final_product_product
      | product_id:
          Map.get(
            updated_final_product_product,
            :product_id,
            existing_final_product_product.product_id
          ),
        final_product_id:
          Map.get(
            updated_final_product_product,
            :final_product_id,
            existing_final_product_product.final_product_id
          ),
        updated_at: current_date_unix
    }

    final_product_product_update_mapper = fn final_product_product ->
      case final_product_product.id == id do
        true ->
          updated_final_product_product

        false ->
          final_product_product
      end
    end

    updated_current_final_product_products =
      current_final_product_products |> Enum.map(final_product_product_update_mapper)

    case write_final_product_products_file_content(updated_current_final_product_products) do
      :ok -> {:ok, updated_final_product_product}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_final_product_products} = read_final_product_products_file()

    updated_current_final_product_products =
      current_final_product_products
      |> Enum.filter(fn final_product_product -> final_product_product.id != id end)

    case write_final_product_products_file_content(updated_current_final_product_products) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
