defmodule SkyRealmRestaurant.Services.InMemoryStore.CategoryService do
  alias SkyRealmRestaurant.Entities.Category
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  @categories_file "in_memory_store/categories.txt"

  defp read_categories_file(), do: FileUtils.read_entities_from_file(@categories_file, Category)

  defp write_categories_file_content(content),
    do: FileUtils.write_entities_to_file(@categories_file, content)

  def find_by_id(id),
    do:
      {:ok,
       Enum.find(read_categories_file(), fn %Category{id: category_id} -> category_id == id end)}

  def find_all(), do: {:ok, read_categories_file()}

  def create(new_category = %Category{}) do
    {:ok, current_categories} = read_categories_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    category_id = GeneralUtils.generate_id("#{length(current_categories)}")

    new_category = %Category{
      new_category
      | id: category_id,
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_categories = [new_category | current_categories]

    case write_categories_file_content(updated_current_categories) do
      :ok -> {:ok, new_category}
      error -> error
    end
  end

  def update(id, updated_category = %Category{}) do
    {:ok, current_categories} = read_categories_file()

    existing_category =
      Enum.find(current_categories, fn %Category{id: category_id} -> category_id == id end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_category = %Category{
      existing_category
      | name: Map.get(updated_category, :name, existing_category.name),
        updated_at: current_date_unix
    }

    category_update_mapper = fn category ->
      case category.id == id do
        true ->
          updated_category

        false ->
          category
      end
    end

    updated_current_categories = current_categories |> Enum.map(category_update_mapper)

    case write_categories_file_content(updated_current_categories) do
      :ok -> {:ok, updated_category}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_categories} = read_categories_file()

    updated_current_categories =
      current_categories |> Enum.filter(fn category -> category.id != id end)

    case write_categories_file_content(updated_current_categories) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
