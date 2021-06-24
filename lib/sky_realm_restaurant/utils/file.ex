defmodule SkyRealmRestaurant.Utils.FileUtils do
  alias SkyRealmRestaurant.Utils.GeneralUtils

  def read_entities_from_file(path, entity_struc) do
    case File.read(path) do
      {:ok, file_content} ->
        entities =
          Jason.decode!(file_content)
          |> Enum.map(fn entity ->
            struct(entity_struc, GeneralUtils.convert_map_to_keyword_list(entity))
          end)

        {:ok, entities}

      _ ->
        {:ok, []}
    end
  end

  def read_queue_from_file(path, queue_struc) do
    case File.read(path) do
      {:ok, file_content} ->
        decoded_queue = Jason.decode!(file_content)
        queue = struct(queue_struc, GeneralUtils.convert_map_to_keyword_list(decoded_queue))

        {:ok, queue}

      _ ->
        {:ok, struct(queue_struc)}
    end
  end

  def write_entities_to_file(path, content), do: File.write(path, Jason.encode!(content))

  def write_queue_to_file(path, queue), do: File.write(path, Jason.encode!(queue))
end
