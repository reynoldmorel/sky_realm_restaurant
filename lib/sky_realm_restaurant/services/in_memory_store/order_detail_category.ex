defmodule SkyRealmRestaurant.Services.InMemoryStore.OrderDetailCategoryService do
  alias SkyRealmRestaurant.Entities.OrderDetailCategory
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @order_detail_categories_file "in_memory_store/order_detail_categories.txt"

  defp read_order_detail_categories_file(),
    do: FileUtils.read_entities_from_file(@order_detail_categories_file, OrderDetailCategory)

  defp write_order_detail_categories_file_content(content),
    do: FileUtils.write_entities_to_file(@order_detail_categories_file, content)

  def find_by_id(id) do
    {:ok, current_order_detail_categories} = read_order_detail_categories_file()

    {:ok,
     current_order_detail_categories
     |> Enum.find(fn %OrderDetailCategory{id: order_detail_category_id} ->
       order_detail_category_id == id
     end)}
  end

  def find_all(), do: read_order_detail_categories_file()

  def find_by_id_enabled(id) do
    {:ok, current_order_detail_categories} = read_order_detail_categories_file()

    {:ok,
     current_order_detail_categories
     |> Enum.find(fn %OrderDetailCategory{id: order_detail_category_id, status: status} ->
       order_detail_category_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_order_detail_categories} = read_order_detail_categories_file()

    {:ok,
     current_order_detail_categories
     |> Enum.filter(fn %OrderDetailCategory{status: status} -> status == Status.enable() end)}
  end

  def find_all_by_order_detail_id_enabled(order_detail_id) do
    {:ok, current_order_detail_categories} = read_order_detail_categories_file()

    {:ok,
     current_order_detail_categories
     |> Enum.filter(fn %OrderDetailCategory{
                         order_detail_id: order_detail_category_order_detail_id,
                         status: status
                       } ->
       order_detail_category_order_detail_id == order_detail_id and status == Status.enable()
     end)}
  end

  def find_all_by_category_id_enabled(category_id) do
    {:ok, current_order_detail_categories} = read_order_detail_categories_file()

    {:ok,
     current_order_detail_categories
     |> Enum.filter(fn %OrderDetailCategory{
                         category_id: order_detail_category_category_id,
                         status: status
                       } ->
       order_detail_category_category_id == category_id and status == Status.enable()
     end)}
  end

  def find_by_order_detail_id_and_category_id_enabled(order_detail_id, category_id) do
    {:ok, current_order_detail_categories} = read_order_detail_categories_file()

    {:ok,
     current_order_detail_categories
     |> Enum.filter(fn %OrderDetailCategory{
                         order_detail_id: order_detail_category_order_detail_id,
                         category_id: order_detail_category_category_id,
                         status: status
                       } ->
       order_detail_category_order_detail_id == order_detail_id and
         order_detail_category_category_id == category_id and status == Status.enable()
     end)}
  end

  def create(new_order_detail_category = %OrderDetailCategory{}) do
    {:ok, current_order_detail_categories} = read_order_detail_categories_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    order_detail_category_id =
      GeneralUtils.generate_id("#{length(current_order_detail_categories)}")

    new_order_detail_category = %OrderDetailCategory{
      new_order_detail_category
      | id: order_detail_category_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_order_detail_categories = [
      new_order_detail_category | current_order_detail_categories
    ]

    case write_order_detail_categories_file_content(updated_current_order_detail_categories) do
      :ok -> {:ok, new_order_detail_category}
      error -> error
    end
  end

  def update(id, updated_order_detail_category = %OrderDetailCategory{}) do
    {:ok, current_order_detail_categories} = read_order_detail_categories_file()

    existing_order_detail_category =
      Enum.find(current_order_detail_categories, fn %OrderDetailCategory{
                                                      id: order_detail_category_id
                                                    } ->
        order_detail_category_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_order_detail_category = %OrderDetailCategory{
      existing_order_detail_category
      | order_detail_id:
          Map.get(
            updated_order_detail_category,
            :order_detail_id,
            existing_order_detail_category.order_detail_id
          ),
        category_id:
          Map.get(
            updated_order_detail_category,
            :category_id,
            existing_order_detail_category.category_id
          ),
        category_name:
          Map.get(
            updated_order_detail_category,
            :category_name,
            existing_order_detail_category.category_name
          ),
        updated_at: current_date_unix
    }

    order_detail_category_update_mapper = fn order_detail_category ->
      case order_detail_category.id == id do
        true ->
          updated_order_detail_category

        false ->
          order_detail_category
      end
    end

    updated_current_order_detail_categories =
      current_order_detail_categories |> Enum.map(order_detail_category_update_mapper)

    case write_order_detail_categories_file_content(updated_current_order_detail_categories) do
      :ok -> {:ok, updated_order_detail_category}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_order_detail_categories} = read_order_detail_categories_file()

    updated_current_order_detail_categories =
      current_order_detail_categories
      |> Enum.filter(fn order_detail_category -> order_detail_category.id != id end)

    case write_order_detail_categories_file_content(updated_current_order_detail_categories) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
