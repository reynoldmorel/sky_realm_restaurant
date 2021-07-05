defmodule SkyRealmRestaurant.Core.QueueItem do
  @derive Jason.Encoder

  @attrs [order_detail_id: nil, final_product_id: nil]

  defstruct @attrs

  def get_attrs, do: @attrs
end
