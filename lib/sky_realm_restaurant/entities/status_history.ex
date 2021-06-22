defmodule SkyRealmRestaurant.Entities.StatusHistory do
  @derive Jason.Encoder

  alias SkyRealmRestaurant.Entities.BaseAttrs

  @attrs BaseAttrs.get_attrs() ++
           [
             id: nil,
             model_id: nil,
             model_type: nil,
             from_status: nil,
             to_status: nil,
             assigned_chef_id: nil,
             from_time: nil,
             to_time: nil
           ]

  defstruct @attrs

  def get_attrs, do: @attrs
end
