defmodule SkyRealmRestaurant.Services.InMemoryStore.OrderService do
  alias SkyRealmRestaurant.Entities.Order
  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Entities.OrderTax
  alias SkyRealmRestaurant.Entities.Tax
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status
  alias SkyRealmRestaurant.Utils.OrderCalculatorUtils

  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailService
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderTaxService

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

  defp create_order_details(_order, []), do: {:ok}

  defp create_order_details(_order, nil), do: {:ok}

  defp create_order_details(
         order = %Order{id: order_id, created_by: created_by, updated_by: updated_by},
         [order_detail | order_details]
       ) do
    order_detail_to_create = %OrderDetail{
      order_detail
      | order_id: order_id,
        created_by: created_by,
        updated_by: updated_by
    }

    case OrderDetailService.create(order_detail_to_create) do
      {:ok, _} ->
        create_order_details(order, order_details)

      error ->
        error
    end
  end

  defp create_order_taxes(_order, []), do: {:ok}

  defp create_order_taxes(_order, nil), do: {:ok}

  defp create_order_taxes(
         order = %Order{
           id: order_id,
           created_by: created_by,
           updated_by: updated_by
         },
         [
           %Tax{id: tax_id, name: tax_name, tax_value: tax_value, tax_percentage: tax_percentage}
           | taxes
         ]
       ) do
    order_tax_to_create = %OrderTax{
      order_id: order_id,
      tax_id: tax_id,
      tax_name: tax_name,
      tax_value: tax_value,
      tax_percentage: tax_percentage,
      created_by: created_by,
      updated_by: updated_by
    }

    case OrderTaxService.create(order_tax_to_create) do
      {:ok, _} ->
        create_order_taxes(order, taxes)

      error ->
        error
    end
  end

  def create(new_order = %Order{order_details: order_details, taxes: taxes}) do
    {:ok, current_orders} = read_orders_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    order_id = GeneralUtils.generate_id("#{length(current_orders)}")

    new_order = OrderCalculatorUtils.calculate_order_totals(new_order)

    order_to_create = %Order{
      new_order
      | id: order_id,
        transaction_date: current_date_unix,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix,
        order_details: nil,
        taxes: nil
    }

    updated_current_orders = [order_to_create | current_orders]

    case write_orders_file_content(updated_current_orders) do
      :ok ->
        {:ok} = create_order_details(order_to_create, order_details)
        {:ok} = create_order_taxes(order_to_create, taxes)
        {:ok, order_to_create}

      error ->
        error
    end
  end

  def update(id, updated_order = %Order{}) do
    {:ok, current_orders} = read_orders_file()

    existing_order = Enum.find(current_orders, fn %Order{id: order_id} -> order_id == id end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_order = %Order{
      existing_order
      | cashier_id: Map.get(updated_order, :cashier_id, existing_order.cashier_id),
        transaction_date:
          Map.get(updated_order, :transaction_date, existing_order.transaction_date),
        subtotal: Map.get(updated_order, :subtotal, existing_order.subtotal),
        tax_total: Map.get(updated_order, :tax_total, existing_order.tax_total),
        total: Map.get(updated_order, :total, existing_order.total),
        paid_amount: Map.get(updated_order, :paid_amount, existing_order.paid_amount),
        returned_amount: Map.get(updated_order, :returned_amount, existing_order.returned_amount),
        order_details: nil,
        taxes: nil,
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
