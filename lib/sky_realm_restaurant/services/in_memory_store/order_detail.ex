defmodule SkyRealmRestaurant.Services.InMemoryStore.OrderDetailService do
  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @order_details_file "in_memory_store/order_details.txt"

  defp read_order_details_file(),
    do: FileUtils.read_entities_from_file(@order_details_file, OrderDetail)

  defp write_order_details_file_content(content),
    do: FileUtils.write_entities_to_file(@order_details_file, content)

  def find_by_id(id) do
    {:ok, current_order_details} = read_order_details_file()

    {:ok,
     current_order_details
     |> Enum.find(fn %OrderDetail{id: order_detail_id} -> order_detail_id == id end)}
  end

  def find_all(), do: read_order_details_file()

  def find_by_id_enabled(id) do
    {:ok, current_order_details} = read_order_details_file()

    {:ok,
     current_order_details
     |> Enum.find(fn %OrderDetail{id: order_detail_id, status: status} ->
       order_detail_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_order_details} = read_order_details_file()

    {:ok,
     current_order_details
     |> Enum.filter(fn %OrderDetail{status: status} -> status == Status.enable() end)}
  end

  def create(new_order_detail = %OrderDetail{}) do
    {:ok, current_order_details} = read_order_details_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    order_detail_id = GeneralUtils.generate_id("#{length(current_order_details)}")

    new_order_detail = %OrderDetail{
      new_order_detail
      | id: order_detail_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_order_details = [new_order_detail | current_order_details]

    case write_order_details_file_content(updated_current_order_details) do
      :ok -> {:ok, new_order_detail}
      error -> error
    end
  end

  def update(id, updated_order_detail = %OrderDetail{}) do
    {:ok, current_order_details} = read_order_details_file()

    existing_order_detail =
      Enum.find(current_order_details, fn %OrderDetail{id: order_detail_id} ->
        order_detail_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_order_detail = %OrderDetail{
      existing_order_detail
      | order_id: Map.get(updated_order_detail, :order_id, existing_order_detail.order_id),
        product_id: Map.get(updated_order_detail, :product_id, existing_order_detail.product_id),
        produt_name:
          Map.get(updated_order_detail, :produt_name, existing_order_detail.produt_name),
        produt_serial:
          Map.get(updated_order_detail, :produt_serial, existing_order_detail.produt_serial),
        difficulty_level:
          Map.get(updated_order_detail, :difficulty_level, existing_order_detail.difficulty_level),
        category_id:
          Map.get(updated_order_detail, :category_id, existing_order_detail.category_id),
        quantity: Map.get(updated_order_detail, :quantity, existing_order_detail.quantity),
        price: Map.get(updated_order_detail, :price, existing_order_detail.price),
        tax_total: Map.get(updated_order_detail, :tax_total, existing_order_detail.tax_total),
        cooking_status:
          Map.get(updated_order_detail, :cooking_status, existing_order_detail.cooking_status),
        preparation_status:
          Map.get(
            updated_order_detail,
            :preparation_status,
            existing_order_detail.preparation_status
          ),
        processing_status:
          Map.get(
            updated_order_detail,
            :processing_status,
            existing_order_detail.processing_status
          ),
        updated_at: current_date_unix
    }

    order_detail_update_mapper = fn order_detail ->
      case order_detail.id == id do
        true ->
          updated_order_detail

        false ->
          order_detail
      end
    end

    updated_current_order_details = current_order_details |> Enum.map(order_detail_update_mapper)

    case write_order_details_file_content(updated_current_order_details) do
      :ok -> {:ok, updated_order_detail}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_order_details} = read_order_details_file()

    updated_current_order_details =
      current_order_details |> Enum.filter(fn order_detail -> order_detail.id != id end)

    case write_order_details_file_content(updated_current_order_details) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
