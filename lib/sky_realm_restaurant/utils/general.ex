defmodule SkyRealmRestaurant.Utils.GeneralUtils do
  def convert_map_to_keyword_list(map),
    do: Enum.map(map, fn {key, value} -> {String.to_existing_atom(key), value} end)

  def generate_id(suffix), do: "#{DateTime.to_unix(DateTime.utc_now())}-#{suffix}"
end
