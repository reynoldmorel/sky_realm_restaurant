defmodule SkyRealmRestaurant.Utils.GeneralUtils do
  def convert_map_to_keyword_list(map) do
    Enum.map(map, fn {key, value} ->
      cond do
        is_atom(key) -> {key, value}
        true -> {String.to_existing_atom(key), value}
      end
    end)
  end

  def generate_id(suffix), do: "#{DateTime.to_unix(DateTime.utc_now())}-#{suffix}"
end
