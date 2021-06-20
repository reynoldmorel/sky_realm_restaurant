defmodule SkyRealmRestaurant.Entities.Order do
  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             processing_status: nil,
             cashier_id: nil,
             transaction_date: nil,
             subtotal: nil,
             tax_total: nil,
             total: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
