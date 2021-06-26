defmodule SkyRealmRestaurant.Services.InMemoryStore.OrderService do
  alias SkyRealmRestaurant.Entities.Order
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @orders_file "in_memory_store/orders.txt"

  defp read_orders_file(), do: FileUtils.read_entities_from_file(@orders_file, Order)

  defp write_orders_file_content(content),
    do: FileUtils.write_entities_to_file(@orders_file, content)

  def find_by_id(id) do
    {:ok, current_orders} = read_orders_file()

    {:ok,
     current_orders
     |> Enum.find(fn %Order{id: order_id} -> order_id == id end)}
  end

  def find_all(), do: read_orders_file()

  def find_by_id_enabled(id) do
    {:ok, current_orders} = read_orders_file()

    {:ok,
     current_orders
     |> Enum.find(fn %Order{id: order_id, status: status} ->
       order_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_orders} = read_orders_file()

    {:ok,
     current_orders
     |> Enum.filter(fn %Order{status: status} -> status == Status.enable() end)}
  end

  def create(new_order = %Order{}) do
    {:ok, current_orders} = read_orders_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    order_id = GeneralUtils.generate_id("#{length(current_orders)}")

    new_order = %Order{
      new_order
      | id: order_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_orders = [new_order | current_orders]

    case write_orders_file_content(updated_current_orders) do
      :ok -> {:ok, new_order}
      error -> error
    end
  end

  def update(id, updated_order = %Order{}) do
    {:ok, current_orders} = read_orders_file()

    existing_order = Enum.find(current_orders, fn %Order{id: order_id} -> order_id == id end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_order = %Order{
      existing_order
      | processing_status:
          Map.get(updated_order, :processing_status, existing_order.processing_status),
        cashier_id: Map.get(updated_order, :cashier_id, existing_order.cashier_id),
        transaction_date:
          Map.get(updated_order, :transaction_date, existing_order.transaction_date),
        subtotal: Map.get(updated_order, :subtotal, existing_order.subtotal),
        tax_total: Map.get(updated_order, :tax_total, existing_order.tax_total),
        total: Map.get(updated_order, :total, existing_order.total),
        updated_at: current_date_unix
    }

    order_update_mapper = fn order ->
      case order.id == id do
        true ->
          updated_order

        false ->
          order
      end
    end

    updated_current_orders = current_orders |> Enum.map(order_update_mapper)

    case write_orders_file_content(updated_current_orders) do
      :ok -> {:ok, updated_order}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_orders} = read_orders_file()

    updated_current_orders = current_orders |> Enum.filter(fn order -> order.id != id end)

    case write_orders_file_content(updated_current_orders) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
