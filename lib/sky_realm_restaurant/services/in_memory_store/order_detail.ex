defmodule SkyRealmRestaurant.Services.InMemoryStore.OrderDetailService do
  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Entities.OrderDetailProduct
  alias SkyRealmRestaurant.Entities.Product
  alias SkyRealmRestaurant.Entities.FinalProduct
  alias SkyRealmRestaurant.Entities.Inventory
  alias SkyRealmRestaurant.Entities.OrderDetailCategory
  alias SkyRealmRestaurant.Entities.OrderDetailTax
  alias SkyRealmRestaurant.Entities.Category
  alias SkyRealmRestaurant.Entities.Tax
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status
  alias SkyRealmRestaurant.Constants.PreparationStatus

  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailProductService
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailCategoryService
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailTaxService

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

  def find_all_by_order_id_enabled(order_id) do
    {:ok, current_order_details} = read_order_details_file()

    {:ok,
     current_order_details
     |> Enum.filter(fn %OrderDetail{order_id: order_detail_order_id, status: status} ->
       order_detail_order_id == order_id and status == Status.enable()
     end)}
  end

  def find_all_ready_to_work_enabled() do
    {:ok, current_order_details} = read_order_details_file()

    {:ok,
     current_order_details
     |> Enum.filter(fn %OrderDetail{
                         preparation_status: order_detail_preparation_status,
                         status: status
                       } ->
       order_detail_preparation_status == nil and
         status == Status.enable()
     end)}
  end

  def find_all_to_prepare_enabled() do
    {:ok, current_order_details} = read_order_details_file()

    {:ok,
     current_order_details
     |> Enum.filter(fn %OrderDetail{
                         preparation_status: order_detail_preparation_status,
                         cooking_step: order_detail_cooking_step,
                         status: status
                       } ->
       order_detail_preparation_status == PreparationStatus.preparing() and
         order_detail_cooking_step == nil and status == Status.enable()
     end)}
  end

  def find_to_prepare_by_id_enabled(id) do
    {:ok, current_order_details} = read_order_details_file()

    {:ok,
     current_order_details
     |> Enum.find(fn %OrderDetail{
                       id: order_detail_id,
                       preparation_status: order_detail_preparation_status,
                       cooking_step: order_detail_cooking_step,
                       status: status
                     } ->
       order_detail_id == id and order_detail_preparation_status == PreparationStatus.preparing() and
         order_detail_cooking_step == nil and status == Status.enable()
     end)}
  end

  defp create_order_detail_product(_order_detail, nil, _measure_unit, _inventory),
    do: raise("Product can not be nil")

  defp create_order_detail_product(_order_detail, _product, _measure_unit, nil),
    do: raise("Inventory can not be nil")

  defp create_order_detail_product(_order_detail, _product, nil, _inventory),
    do: raise("Measure Unit can not be nil")

  defp create_order_detail_product(
         %OrderDetail{
           id: order_detail_id,
           created_by: created_by,
           updated_by: updated_by
         },
         %Product{
           id: product_id,
           name: produt_name,
           display_name: produt_display_name,
           serial: produt_serial
         },
         measure_unit,
         %Inventory{id: inventory_id}
       ) do
    order_detail_product_to_create = %OrderDetailProduct{
      order_detail_id: order_detail_id,
      product_id: product_id,
      produt_name: produt_name,
      produt_display_name: produt_display_name,
      produt_serial: produt_serial,
      difficulty_level: nil,
      is_final_product: false,
      measure_unit: measure_unit,
      inventory_id: inventory_id,
      created_by: created_by,
      updated_by: updated_by
    }

    case OrderDetailProductService.create(order_detail_product_to_create) do
      {:ok, _} ->
        {:ok}

      error ->
        error
    end
  end

  defp create_order_detail_product(
         %OrderDetail{
           id: order_detail_id,
           created_by: created_by,
           updated_by: updated_by
         },
         %FinalProduct{
           id: product_id,
           name: produt_name,
           display_name: produt_display_name,
           serial: produt_serial,
           difficulty_level: difficulty_level,
           cooking_steps: cooking_steps
         },
         measure_unit,
         %Inventory{id: inventory_id}
       ) do
    order_detail_product_to_create = %OrderDetailProduct{
      order_detail_id: order_detail_id,
      product_id: product_id,
      produt_name: produt_name,
      produt_display_name: produt_display_name,
      produt_serial: produt_serial,
      difficulty_level: difficulty_level,
      is_final_product: true,
      measure_unit: measure_unit,
      inventory_id: inventory_id,
      cooking_steps: cooking_steps,
      created_by: created_by,
      updated_by: updated_by
    }

    case OrderDetailProductService.create(order_detail_product_to_create) do
      {:ok, _} ->
        {:ok}

      error ->
        error
    end
  end

  defp create_order_detail_categories(_order_detail, []), do: {:ok}

  defp create_order_detail_categories(_order_detail, nil), do: {:ok}

  defp create_order_detail_categories(
         order_detail = %OrderDetail{
           id: order_detail_id,
           created_by: created_by,
           updated_by: updated_by
         },
         [%Category{id: category_id, name: category_name} | categories]
       ) do
    order_detail_category_to_create = %OrderDetailCategory{
      order_detail_id: order_detail_id,
      category_id: category_id,
      category_name: category_name,
      created_by: created_by,
      updated_by: updated_by
    }

    case OrderDetailCategoryService.create(order_detail_category_to_create) do
      {:ok, _} ->
        create_order_detail_categories(order_detail, categories)

      error ->
        error
    end
  end

  defp create_order_detail_taxes(_order_detail, []), do: {:ok}

  defp create_order_detail_taxes(_order_detail, nil), do: {:ok}

  defp create_order_detail_taxes(
         order_detail = %OrderDetail{
           id: order_detail_id,
           created_by: created_by,
           updated_by: updated_by
         },
         [
           %Tax{id: tax_id, name: tax_name, tax_value: tax_value, tax_percentage: tax_percentage}
           | taxes
         ]
       ) do
    order_detail_tax_to_create = %OrderDetailTax{
      order_detail_id: order_detail_id,
      tax_id: tax_id,
      tax_name: tax_name,
      tax_value: tax_value,
      tax_percentage: tax_percentage,
      created_by: created_by,
      updated_by: updated_by
    }

    case OrderDetailTaxService.create(order_detail_tax_to_create) do
      {:ok, _} ->
        create_order_detail_taxes(order_detail, taxes)

      error ->
        error
    end
  end

  def create(
        new_order_detail = %OrderDetail{
          product: product,
          selected_measure_unit: selected_measure_unit,
          inventory: inventory,
          categories: categories,
          taxes: taxes
        }
      ) do
    {:ok, current_order_details} = read_order_details_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    order_detail_id = GeneralUtils.generate_id("#{length(current_order_details)}")

    order_detail_to_create = %OrderDetail{
      new_order_detail
      | id: order_detail_id,
        product: nil,
        categories: nil,
        taxes: nil,
        selected_measure_unit: nil,
        inventory: nil,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_order_details = [order_detail_to_create | current_order_details]

    case write_order_details_file_content(updated_current_order_details) do
      :ok ->
        {:ok} =
          create_order_detail_product(
            order_detail_to_create,
            product,
            selected_measure_unit,
            inventory
          )

        {:ok} = create_order_detail_categories(order_detail_to_create, categories)

        {:ok} = create_order_detail_taxes(order_detail_to_create, taxes)

        {:ok, order_detail_to_create}

      error ->
        error
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
        quantity: Map.get(updated_order_detail, :quantity, existing_order_detail.quantity),
        price: Map.get(updated_order_detail, :price, existing_order_detail.price),
        tax_total: Map.get(updated_order_detail, :tax_total, existing_order_detail.tax_total),
        cooking_step:
          Map.get(updated_order_detail, :cooking_step, existing_order_detail.cooking_step),
        preparation_status:
          Map.get(
            updated_order_detail,
            :preparation_status,
            existing_order_detail.preparation_status
          ),
        categories: nil,
        product: nil,
        taxes: nil,
        selected_measure_unit: nil,
        inventory: nil,
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
