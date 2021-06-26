defmodule SkyRealmRestaurant.Services.InMemoryStore.ProductService do
  alias SkyRealmRestaurant.Entities.Product
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @products_file "in_memory_store/products.txt"

  defp read_products_file(),
    do: FileUtils.read_entities_from_file(@products_file, Product)

  defp write_products_file_content(content),
    do: FileUtils.write_entities_to_file(@products_file, content)

  def find_by_id(id) do
    {:ok, current_products} = read_products_file()

    {:ok,
     current_products
     |> Enum.find(fn %Product{id: product_id} -> product_id == id end)}
  end

  def find_all(), do: read_products_file()

  def find_by_id_enabled(id) do
    {:ok, current_products} = read_products_file()

    {:ok,
     current_products
     |> Enum.find(fn %Product{id: product_id, status: status} ->
       product_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_products} = read_products_file()

    {:ok,
     current_products
     |> Enum.filter(fn %Product{status: status} -> status == Status.enable() end)}
  end

  def find_by_serial_enabled(serial) do
    {:ok, current_products} = read_products_file()

    {:ok,
     current_products
     |> Enum.find(fn %Product{serial: product_serial, status: status} ->
       product_serial == serial and status == Status.enable()
     end)}
  end

  def create(new_product = %Product{}) do
    {:ok, current_products} = read_products_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    product_id = GeneralUtils.generate_id("#{length(current_products)}")

    new_product = %Product{
      new_product
      | id: product_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_products = [new_product | current_products]

    case write_products_file_content(updated_current_products) do
      :ok -> {:ok, new_product}
      error -> error
    end
  end

  def update(id, updated_product = %Product{}) do
    {:ok, current_products} = read_products_file()

    existing_product =
      Enum.find(current_products, fn %Product{id: product_id} ->
        product_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_product = %Product{
      existing_product
      | parent_product_id:
          Map.get(
            updated_product,
            :parent_product_id,
            existing_product.parent_product_id
          ),
        serial: Map.get(updated_product, :serial, existing_product.serial),
        name: Map.get(updated_product, :name, existing_product.name),
        display_name: Map.get(updated_product, :display_name, existing_product.display_name),
        price: Map.get(updated_product, :price, existing_product.price),
        supported_measure_units:
          Map.get(
            updated_product,
            :supported_measure_units,
            existing_product.supported_measure_units
          ),
        updated_at: current_date_unix
    }

    product_update_mapper = fn product ->
      case product.id == id do
        true ->
          updated_product

        false ->
          product
      end
    end

    updated_current_products = current_products |> Enum.map(product_update_mapper)

    case write_products_file_content(updated_current_products) do
      :ok -> {:ok, updated_product}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_products} = read_products_file()

    updated_current_products = current_products |> Enum.filter(fn product -> product.id != id end)

    case write_products_file_content(updated_current_products) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
