defmodule SkyRealmRestaurant.Services.InMemoryStore.ProductCategoryService do
  alias SkyRealmRestaurant.Entities.ProductCategory
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @product_categories_file "in_memory_store/product_categories.txt"

  defp read_product_categories_file(),
    do: FileUtils.read_entities_from_file(@product_categories_file, ProductCategory)

  defp write_product_categories_file_content(content),
    do: FileUtils.write_entities_to_file(@product_categories_file, content)

  def find_by_id(id) do
    {:ok, current_product_categories} = read_product_categories_file()

    {:ok,
     current_product_categories
     |> Enum.find(fn %ProductCategory{id: product_category_id} -> product_category_id == id end)}
  end

  def find_all(), do: read_product_categories_file()

  def find_by_id_enabled(id) do
    {:ok, current_product_categories} = read_product_categories_file()

    {:ok,
     current_product_categories
     |> Enum.find(fn %ProductCategory{id: product_category_id, status: status} ->
       product_category_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_product_categories} = read_product_categories_file()

    {:ok,
     current_product_categories
     |> Enum.filter(fn %ProductCategory{status: status} -> status == Status.enable() end)}
  end

  def find_all_by_cateogory_id_enabled(category_id) do
    {:ok, current_product_categories} = read_product_categories_file()

    {:ok,
     current_product_categories
     |> Enum.filter(fn %ProductCategory{
                         category_id: product_category_category_id,
                         status: status
                       } ->
       product_category_category_id == category_id and status == Status.enable()
     end)}
  end

  def find_all_by_product_id_enabled(product_id) do
    {:ok, current_product_categories} = read_product_categories_file()

    {:ok,
     current_product_categories
     |> Enum.filter(fn %ProductCategory{
                         product_id: product_category_product_id,
                         status: status
                       } ->
       product_category_product_id == product_id and status == Status.enable()
     end)}
  end

  def find_by_cateogory_id_and_product_id_enabled(category_id, product_id) do
    {:ok, current_product_categories} = read_product_categories_file()

    {:ok,
     current_product_categories
     |> Enum.filter(fn %ProductCategory{
                         category_id: product_category_category_id,
                         product_id: product_category_product_id,
                         status: status
                       } ->
       product_category_category_id == category_id and product_category_product_id == product_id and
         status == Status.enable()
     end)}
  end

  def create(new_product_category = %ProductCategory{}) do
    {:ok, current_product_categories} = read_product_categories_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    product_category_id = GeneralUtils.generate_id("#{length(current_product_categories)}")

    new_product_category = %ProductCategory{
      new_product_category
      | id: product_category_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_product_categories = [
      new_product_category | current_product_categories
    ]

    case write_product_categories_file_content(updated_current_product_categories) do
      :ok -> {:ok, new_product_category}
      error -> error
    end
  end

  def update(id, updated_product_category = %ProductCategory{}) do
    {:ok, current_product_categories} = read_product_categories_file()

    existing_product_category =
      Enum.find(current_product_categories, fn %ProductCategory{
                                                 id: product_category_id
                                               } ->
        product_category_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_product_category = %ProductCategory{
      existing_product_category
      | product_id:
          Map.get(
            updated_product_category,
            :product_id,
            existing_product_category.product_id
          ),
        category_id:
          Map.get(
            updated_product_category,
            :category_id,
            existing_product_category.category_id
          ),
        updated_at: current_date_unix
    }

    product_category_update_mapper = fn product_category ->
      case product_category.id == id do
        true ->
          updated_product_category

        false ->
          product_category
      end
    end

    updated_current_product_categories =
      current_product_categories |> Enum.map(product_category_update_mapper)

    case write_product_categories_file_content(updated_current_product_categories) do
      :ok -> {:ok, updated_product_category}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_product_categories} = read_product_categories_file()

    updated_current_product_categories =
      current_product_categories
      |> Enum.filter(fn product_category -> product_category.id != id end)

    case write_product_categories_file_content(updated_current_product_categories) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
