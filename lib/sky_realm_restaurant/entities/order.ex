defmodule SkyRealmRestaurant.Entities.Order do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             cashier_id: nil,
             transaction_date: nil,
             subtotal: 0.0,
             tax_total: 0.0,
             paid_amount: 0.0,
             returned_amount: 0.0,
             total: 0.0,
             order_details: nil,
             taxes: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
