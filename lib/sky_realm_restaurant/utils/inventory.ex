defmodule SkyRealmRestaurant.Utils.InventoryUtils do
  alias SkyRealmRestaurant.Services.InMemoryStore.OrderDetailProductService
  alias SkyRealmRestaurant.Services.InMemoryStore.InventoryProductService
  alias SkyRealmRestaurant.Services.InMemoryStore.FinalProductProductService

  alias SkyRealmRestaurant.Constants.MeasureUnit

  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Entities.OrderDetailProduct
  alias SkyRealmRestaurant.Entities.InventoryProduct
  alias SkyRealmRestaurant.Entities.FinalProductProduct

  alias SkyRealmRestaurant.Utils.GeneralUtils

  def validate_order_details_with_final_product_products_and_update_inventory(
        validation_map = %{},
        [],
        _order_detail,
        _order_detail_product
      ),
      do: validation_map

  def validate_order_details_with_final_product_products_and_update_inventory(
        validation_map = %{},
        [final_product_product = %FinalProductProduct{} | final_product_products],
        order_detail = %OrderDetail{},
        order_detail_product = %OrderDetailProduct{}
      ) do
    {:ok, [inventory_product = %InventoryProduct{} | _]} =
      InventoryProductService.find_all_by_product_id_enabled(final_product_product.product_id)

    order_detail_product_measure_unit =
      struct(
        MeasureUnit,
        GeneralUtils.convert_map_to_keyword_list(order_detail_product.measure_unit)
      )

    final_product_product_measure_unit =
      struct(
        MeasureUnit,
        GeneralUtils.convert_map_to_keyword_list(final_product_product.measure_unit)
      )

    inventory_product_measure_unit =
      struct(
        MeasureUnit,
        GeneralUtils.convert_map_to_keyword_list(inventory_product.measure_unit)
      )

    order_detail_quantity_in_units =
      order_detail.quantity * order_detail_product_measure_unit.units

    final_product_product_quantity_in_units =
      final_product_product.quantity *
        final_product_product_measure_unit.units

    requested_product_quantity_in_units =
      order_detail_quantity_in_units * final_product_product_quantity_in_units

    available_quantity_in_units =
      inventory_product.quantity * inventory_product_measure_unit.units

    updated_quantity_availability =
      available_quantity_in_units - requested_product_quantity_in_units

    case updated_quantity_availability > 0 do
      true ->
        case InventoryProductService.update(
               inventory_product.id,
               %InventoryProduct{
                 inventory_product
                 | quantity: updated_quantity_availability
               }
             ) do
          {:ok, _} ->
            updated_validation_map =
              Map.put(
                validation_map,
                order_detail.id,
                Map.get(validation_map, order_detail.id, true) and true
              )

            validate_order_details_with_final_product_products_and_update_inventory(
              updated_validation_map,
              final_product_products,
              order_detail,
              order_detail_product
            )

          error ->
            error
        end

      false ->
        Map.put(validation_map, order_detail.id, false)
    end
  end

  def validate_order_details_with_products_and_update_inventory(
        validation_map = %{},
        order_detail = %OrderDetail{},
        order_detail_product = %OrderDetailProduct{}
      ) do
    {:ok, [inventory_product = %InventoryProduct{} | _]} =
      InventoryProductService.find_all_by_product_id_enabled(order_detail_product.product_id)

    order_detail_product_measure_unit =
      struct(
        MeasureUnit,
        GeneralUtils.convert_map_to_keyword_list(order_detail_product.measure_unit)
      )

    inventory_product_measure_unit =
      struct(
        MeasureUnit,
        GeneralUtils.convert_map_to_keyword_list(inventory_product.measure_unit)
      )

    requested_product_quantity_in_units =
      order_detail.quantity * order_detail_product_measure_unit.units

    available_quantity_in_units =
      inventory_product.quantity * inventory_product_measure_unit.units

    updated_quantity_availability =
      available_quantity_in_units - requested_product_quantity_in_units

    case updated_quantity_availability > 0 do
      true ->
        case InventoryProductService.update(
               inventory_product.id,
               %InventoryProduct{
                 inventory_product
                 | quantity: updated_quantity_availability
               }
             ) do
          {:ok, _} ->
            Map.put(
              validation_map,
              order_detail.id,
              Map.get(validation_map, order_detail.id, true) and true
            )

          error ->
            error
        end

      false ->
        Map.put(validation_map, order_detail.id, false)
    end
  end

  def validate_order_details_and_update_inventory(
        order_details,
        validation_map \\ %{}
      )

  def validate_order_details_and_update_inventory([], validation_map),
    do: {:ok, validation_map}

  def validate_order_details_and_update_inventory(
        [order_detail = %OrderDetail{} | order_details],
        validation_map
      ) do
    {:ok, [order_detail_product = %OrderDetailProduct{} | _]} =
      OrderDetailProductService.find_all_by_order_detail_id_enabled(order_detail.id)

    validation_map =
      case order_detail_product.is_final_product do
        true ->
          {:ok, final_product_products} =
            FinalProductProductService.find_all_by_final_product_id_enabled(
              order_detail_product.product_id
            )

          validate_order_details_with_final_product_products_and_update_inventory(
            validation_map,
            final_product_products,
            order_detail,
            order_detail_product
          )

        false ->
          validate_order_details_with_products_and_update_inventory(
            validation_map,
            order_detail,
            order_detail_product
          )
      end

    validate_order_details_and_update_inventory(
      order_details,
      validation_map
    )
  end
end
