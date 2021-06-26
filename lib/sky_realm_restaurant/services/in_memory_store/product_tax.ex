defmodule SkyRealmRestaurant.Services.InMemoryStore.ProductTaxService do
  alias SkyRealmRestaurant.Entities.ProductTax
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @product_taxes_file "in_memory_store/product_taxes.txt"

  defp read_product_taxes_file(),
    do: FileUtils.read_entities_from_file(@product_taxes_file, ProductTax)

  defp write_product_taxes_file_content(content),
    do: FileUtils.write_entities_to_file(@product_taxes_file, content)

  def find_by_id(id) do
    {:ok, current_product_taxes} = read_product_taxes_file()

    {:ok,
     current_product_taxes
     |> Enum.find(fn %ProductTax{id: product_tax_id} -> product_tax_id == id end)}
  end

  def find_all(), do: read_product_taxes_file()

  def find_by_id_enabled(id) do
    {:ok, current_product_taxes} = read_product_taxes_file()

    {:ok,
     current_product_taxes
     |> Enum.find(fn %ProductTax{id: product_tax_id, status: status} ->
       product_tax_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_product_taxes} = read_product_taxes_file()

    {:ok,
     current_product_taxes
     |> Enum.filter(fn %ProductTax{status: status} -> status == Status.enable() end)}
  end

  def create(new_product_tax = %ProductTax{}) do
    {:ok, current_product_taxes} = read_product_taxes_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    product_tax_id = GeneralUtils.generate_id("#{length(current_product_taxes)}")

    new_product_tax = %ProductTax{
      new_product_tax
      | id: product_tax_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_product_taxes = [new_product_tax | current_product_taxes]

    case write_product_taxes_file_content(updated_current_product_taxes) do
      :ok -> {:ok, new_product_tax}
      error -> error
    end
  end

  def update(id, updated_product_tax = %ProductTax{}) do
    {:ok, current_product_taxes} = read_product_taxes_file()

    existing_product_tax =
      Enum.find(current_product_taxes, fn %ProductTax{id: product_tax_id} ->
        product_tax_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_product_tax = %ProductTax{
      existing_product_tax
      | product_id:
          Map.get(
            updated_product_tax,
            :product_id,
            existing_product_tax.product_id
          ),
        tax_id:
          Map.get(
            updated_product_tax,
            :tax_id,
            existing_product_tax.tax_id
          ),
        updated_at: current_date_unix
    }

    product_tax_update_mapper = fn product_tax ->
      case product_tax.id == id do
        true ->
          updated_product_tax

        false ->
          product_tax
      end
    end

    updated_current_product_taxes = current_product_taxes |> Enum.map(product_tax_update_mapper)

    case write_product_taxes_file_content(updated_current_product_taxes) do
      :ok -> {:ok, updated_product_tax}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_product_taxes} = read_product_taxes_file()

    updated_current_product_taxes =
      current_product_taxes |> Enum.filter(fn product_tax -> product_tax.id != id end)

    case write_product_taxes_file_content(updated_current_product_taxes) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
