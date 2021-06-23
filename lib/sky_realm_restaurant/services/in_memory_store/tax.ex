defmodule SkyRealmRestaurant.Services.InMemoryStore.TaxService do
  alias SkyRealmRestaurant.Entities.Tax
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  @taxes_file "in_memory_store/taxes.txt"

  defp read_taxes_file(), do: FileUtils.read_entities_from_file(@taxes_file, Tax)

  defp write_taxes_file_content(content),
    do: FileUtils.write_entities_to_file(@taxes_file, content)

  def find_by_id(id),
    do: {:ok, Enum.find(read_taxes_file(), fn %Tax{id: tax_id} -> tax_id == id end)}

  def find_all(), do: {:ok, read_taxes_file()}

  def create(new_tax = %Tax{}) do
    {:ok, current_taxes} = read_taxes_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    tax_id = GeneralUtils.generate_id("#{length(current_taxes)}")

    new_tax = %Tax{
      new_tax
      | id: tax_id,
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_taxes = [new_tax | current_taxes]

    case write_taxes_file_content(updated_current_taxes) do
      :ok -> {:ok, new_tax}
      error -> error
    end
  end

  def update(id, updated_tax = %Tax{}) do
    {:ok, current_taxes} = read_taxes_file()

    existing_tax = Enum.find(current_taxes, fn %Tax{id: tax_id} -> tax_id == id end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_tax = %Tax{
      existing_tax
      | tax_value: Map.get(updated_tax, :tax_value, existing_tax.tax_value),
        name: Map.get(updated_tax, :name, existing_tax.name),
        tax_percentage: Map.get(updated_tax, :tax_percentage, existing_tax.tax_percentage),
        is_order: Map.get(updated_tax, :is_order, existing_tax.is_order),
        is_product: Map.get(updated_tax, :is_product, existing_tax.is_product),
        updated_at: current_date_unix
    }

    tax_update_mapper = fn tax ->
      case tax.id == id do
        true ->
          updated_tax

        false ->
          tax
      end
    end

    updated_current_taxes = current_taxes |> Enum.map(tax_update_mapper)

    case write_taxes_file_content(updated_current_taxes) do
      :ok -> {:ok, updated_tax}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_taxes} = read_taxes_file()

    updated_current_taxes = current_taxes |> Enum.filter(fn tax -> tax.id != id end)

    case write_taxes_file_content(updated_current_taxes) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
