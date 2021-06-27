defmodule SkyRealmRestaurant.Services.InMemoryStore.OrderTaxService do
  alias SkyRealmRestaurant.Entities.OrderTax
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @order_taxes_file "in_memory_store/order_taxes.txt"

  defp read_order_taxes_file(),
    do: FileUtils.read_entities_from_file(@order_taxes_file, OrderTax)

  defp write_order_taxes_file_content(content),
    do: FileUtils.write_entities_to_file(@order_taxes_file, content)

  def find_by_id(id) do
    {:ok, current_order_taxes} = read_order_taxes_file()

    {:ok,
     current_order_taxes
     |> Enum.find(fn %OrderTax{id: order_tax_id} ->
       order_tax_id == id
     end)}
  end

  def find_all(), do: read_order_taxes_file()

  def find_by_id_enabled(id) do
    {:ok, current_order_taxes} = read_order_taxes_file()

    {:ok,
     current_order_taxes
     |> Enum.find(fn %OrderTax{id: order_tax_id, status: status} ->
       order_tax_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_order_taxes} = read_order_taxes_file()

    {:ok,
     current_order_taxes
     |> Enum.filter(fn %OrderTax{status: status} -> status == Status.enable() end)}
  end

  def find_all_by_order_id_enabled(order_id) do
    {:ok, current_order_taxes} = read_order_taxes_file()

    {:ok,
     current_order_taxes
     |> Enum.filter(fn %OrderTax{
                         order_id: order_tax_order_id,
                         status: status
                       } ->
       order_tax_order_id == order_id and status == Status.enable()
     end)}
  end

  def find_all_by_tax_id_enabled(tax_id) do
    {:ok, current_order_taxes} = read_order_taxes_file()

    {:ok,
     current_order_taxes
     |> Enum.filter(fn %OrderTax{
                         tax_id: order_tax_tax_id,
                         status: status
                       } ->
       order_tax_tax_id == tax_id and status == Status.enable()
     end)}
  end

  def find_by_order_id_and_tax_id_enabled(order_id, tax_id) do
    {:ok, current_order_taxes} = read_order_taxes_file()

    {:ok,
     current_order_taxes
     |> Enum.filter(fn %OrderTax{
                         order_id: order_tax_order_id,
                         tax_id: order_tax_tax_id,
                         status: status
                       } ->
       order_tax_order_id == order_id and order_tax_tax_id == tax_id and status == Status.enable()
     end)}
  end

  def create(new_order_tax = %OrderTax{}) do
    {:ok, current_order_taxes} = read_order_taxes_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    order_tax_id = GeneralUtils.generate_id("#{length(current_order_taxes)}")

    new_order_tax = %OrderTax{
      new_order_tax
      | id: order_tax_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_order_taxes = [
      new_order_tax | current_order_taxes
    ]

    case write_order_taxes_file_content(updated_current_order_taxes) do
      :ok -> {:ok, new_order_tax}
      error -> error
    end
  end

  def update(id, updated_order_tax = %OrderTax{}) do
    {:ok, current_order_taxes} = read_order_taxes_file()

    existing_order_tax =
      Enum.find(current_order_taxes, fn %OrderTax{
                                          id: order_tax_id
                                        } ->
        order_tax_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_order_tax = %OrderTax{
      existing_order_tax
      | order_id:
          Map.get(
            updated_order_tax,
            :order_id,
            existing_order_tax.order_id
          ),
        tax_id:
          Map.get(
            updated_order_tax,
            :tax_id,
            existing_order_tax.tax_id
          ),
        tax_percentage:
          Map.get(
            updated_order_tax,
            :tax_percentage,
            existing_order_tax.tax_percentage
          ),
        tax_value:
          Map.get(
            updated_order_tax,
            :tax_value,
            existing_order_tax.tax_value
          ),
        updated_at: current_date_unix
    }

    order_tax_update_mapper = fn order_tax ->
      case order_tax.id == id do
        true ->
          updated_order_tax

        false ->
          order_tax
      end
    end

    updated_current_order_taxes = current_order_taxes |> Enum.map(order_tax_update_mapper)

    case write_order_taxes_file_content(updated_current_order_taxes) do
      :ok -> {:ok, updated_order_tax}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_order_taxes} = read_order_taxes_file()

    updated_current_order_taxes =
      current_order_taxes
      |> Enum.filter(fn order_tax -> order_tax.id != id end)

    case write_order_taxes_file_content(updated_current_order_taxes) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
