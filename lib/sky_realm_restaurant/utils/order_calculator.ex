defmodule SkyRealmRestaurant.Utils.OrderCalculatorUtils do
  alias SkyRealmRestaurant.Entities.Order
  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Entities.Tax

  def calculate_tax_total(nil), do: 0

  def calculate_tax_total(taxes),
    do:
      taxes
      |> Enum.reduce(0, fn %Tax{tax_value: tax_value}, tax_total ->
        tax_value + tax_total
      end)

  def calculate_order_details_totals(nil), do: {0, 0, 0}

  def calculate_order_details_totals(order_details),
    do:
      order_details
      |> Enum.reduce({0, 0, 0}, fn %OrderDetail{
                                     taxes: order_detail_taxes,
                                     quantity: quantity,
                                     price: price,
                                     selected_measure_unit: %{units: units}
                                   },
                                   {order_details_subtotal, order_detail_subtotal_taxt_total,
                                    order_details_total} ->
        order_detail_tax_total = calculate_tax_total(order_detail_taxes)
        subtotal = units * quantity * price
        order_details_subtotal = subtotal + order_details_subtotal

        order_detail_subtotal_taxt_total =
          order_detail_subtotal_taxt_total + subtotal * order_detail_tax_total

        order_details_total = order_details_total + subtotal + order_detail_subtotal_taxt_total
        {order_details_subtotal, order_detail_subtotal_taxt_total, order_details_total}
      end)

  def calculate_order_totals(
        order = %Order{paid_amount: paid_amount, taxes: order_taxes, order_details: order_details}
      ) do
    order_tax_total = calculate_tax_total(order_taxes)

    {order_details_subtotal, order_detail_subtotal_taxt_total, _order_details_total} =
      calculate_order_details_totals(order_details)

    order_subtotal_tax_total = order_details_subtotal * order_tax_total

    order_total =
      order_details_subtotal + order_detail_subtotal_taxt_total + order_subtotal_tax_total

    %Order{
      order
      | subtotal: order_details_subtotal,
        tax_total: order_tax_total,
        total: order_total,
        returned_amount: paid_amount - order_total
    }
  end
end
