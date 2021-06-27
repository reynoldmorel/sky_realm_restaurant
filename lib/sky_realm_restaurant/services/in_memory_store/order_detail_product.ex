defmodule SkyRealmRestaurant.Services.InMemoryStore.OrderDetailProductService do
  alias SkyRealmRestaurant.Entities.OrderDetailProduct
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @order_detail_products_file "in_memory_store/order_detail_products.txt"

  defp read_order_detail_products_file(),
    do: FileUtils.read_entities_from_file(@order_detail_products_file, OrderDetailProduct)

  defp write_order_detail_products_file_content(content),
    do: FileUtils.write_entities_to_file(@order_detail_products_file, content)

  def find_by_id(id) do
    {:ok, current_order_detail_products} = read_order_detail_products_file()

    {:ok,
     current_order_detail_products
     |> Enum.find(fn %OrderDetailProduct{id: order_detail_product_id} ->
       order_detail_product_id == id
     end)}
  end

  def find_all(), do: read_order_detail_products_file()

  def find_by_id_enabled(id) do
    {:ok, current_order_detail_products} = read_order_detail_products_file()

    {:ok,
     current_order_detail_products
     |> Enum.find(fn %OrderDetailProduct{id: order_detail_product_id, status: status} ->
       order_detail_product_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_order_detail_products} = read_order_detail_products_file()

    {:ok,
     current_order_detail_products
     |> Enum.filter(fn %OrderDetailProduct{status: status} -> status == Status.enable() end)}
  end

  def find_all_by_order_detail_id_enabled(order_detail_id) do
    {:ok, current_order_detail_products} = read_order_detail_products_file()

    {:ok,
     current_order_detail_products
     |> Enum.filter(fn %OrderDetailProduct{
                         order_detail_id: order_detail_product_order_detail_id,
                         status: status
                       } ->
       order_detail_product_order_detail_id == order_detail_id and status == Status.enable()
     end)}
  end

  def find_all_by_prdduct_id_enabled(prdduct_id, is_final_product) do
    {:ok, current_order_detail_products} = read_order_detail_products_file()

    {:ok,
     current_order_detail_products
     |> Enum.filter(fn %OrderDetailProduct{
                         product_id: order_detail_product_prdduct_id,
                         is_final_product: order_detail_product_is_final_product,
                         status: status
                       } ->
       order_detail_product_prdduct_id == prdduct_id and status == Status.enable() and
         order_detail_product_is_final_product == is_final_product
     end)}
  end

  def find_by_order_detail_id_and_product_id_enabled(order_detail_id, product_id) do
    {:ok, current_order_detail_products} = read_order_detail_products_file()

    {:ok,
     current_order_detail_products
     |> Enum.filter(fn %OrderDetailProduct{
                         order_detail_id: order_detail_product_order_detail_id,
                         product_id: order_detail_product_product_id,
                         status: status
                       } ->
       order_detail_product_order_detail_id == order_detail_id and
         order_detail_product_product_id == product_id and status == Status.enable()
     end)}
  end

  def create(new_order_detail_product = %OrderDetailProduct{}) do
    {:ok, current_order_detail_products} = read_order_detail_products_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    order_detail_product_id = GeneralUtils.generate_id("#{length(current_order_detail_products)}")

    new_order_detail_product = %OrderDetailProduct{
      new_order_detail_product
      | id: order_detail_product_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_order_detail_products = [
      new_order_detail_product | current_order_detail_products
    ]

    case write_order_detail_products_file_content(updated_current_order_detail_products) do
      :ok -> {:ok, new_order_detail_product}
      error -> error
    end
  end

  def update(id, updated_order_detail_product = %OrderDetailProduct{}) do
    {:ok, current_order_detail_products} = read_order_detail_products_file()

    existing_order_detail_product =
      Enum.find(current_order_detail_products, fn %OrderDetailProduct{
                                                    id: order_detail_product_id
                                                  } ->
        order_detail_product_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_order_detail_product = %OrderDetailProduct{
      existing_order_detail_product
      | order_detail_id:
          Map.get(
            updated_order_detail_product,
            :order_detail_id,
            existing_order_detail_product.order_detail_id
          ),
        product_id:
          Map.get(
            updated_order_detail_product,
            :product_id,
            existing_order_detail_product.product_id
          ),
        produt_name:
          Map.get(
            updated_order_detail_product,
            :produt_name,
            existing_order_detail_product.produt_name
          ),
        produt_display_name:
          Map.get(
            updated_order_detail_product,
            :produt_display_name,
            existing_order_detail_product.produt_display_name
          ),
        produt_serial:
          Map.get(
            updated_order_detail_product,
            :produt_serial,
            existing_order_detail_product.produt_serial
          ),
        difficulty_level:
          Map.get(
            updated_order_detail_product,
            :difficulty_level,
            existing_order_detail_product.difficulty_level
          ),
        is_final_product:
          Map.get(
            updated_order_detail_product,
            :is_final_product,
            existing_order_detail_product.is_final_product
          ),
        measure_unit:
          Map.get(
            updated_order_detail_product,
            :measure_unit,
            existing_order_detail_product.measure_unit
          ),
        inventory_id:
          Map.get(
            updated_order_detail_product,
            :inventory_id,
            existing_order_detail_product.inventory_id
          ),
        cooking_steps:
          Map.get(
            updated_order_detail_product,
            :cooking_steps,
            existing_order_detail_product.cooking_steps
          ),
        updated_at: current_date_unix
    }

    order_detail_product_update_mapper = fn order_detail_product ->
      case order_detail_product.id == id do
        true ->
          updated_order_detail_product

        false ->
          order_detail_product
      end
    end

    updated_current_order_detail_products =
      current_order_detail_products |> Enum.map(order_detail_product_update_mapper)

    case write_order_detail_products_file_content(updated_current_order_detail_products) do
      :ok -> {:ok, updated_order_detail_product}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_order_detail_products} = read_order_detail_products_file()

    updated_current_order_detail_products =
      current_order_detail_products
      |> Enum.filter(fn order_detail_product -> order_detail_product.id != id end)

    case write_order_detail_products_file_content(updated_current_order_detail_products) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
