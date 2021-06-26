defmodule SkyRealmRestaurant.Services.InMemoryStore.StatusHistoryService do
  alias SkyRealmRestaurant.Entities.StatusHistory
  alias SkyRealmRestaurant.Utils.GeneralUtils
  alias SkyRealmRestaurant.Utils.FileUtils
  alias SkyRealmRestaurant.Constants.Status

  @status_histories_file "in_memory_store/status_histories.txt"

  defp read_status_histories_file(),
    do: FileUtils.read_entities_from_file(@status_histories_file, StatusHistory)

  defp write_status_histories_file_content(content),
    do: FileUtils.write_entities_to_file(@status_histories_file, content)

  def find_by_id(id) do
    {:ok, current_status_histories} = read_status_histories_file()

    {:ok,
     current_status_histories
     |> Enum.find(fn %StatusHistory{id: status_history_id} -> status_history_id == id end)}
  end

  def find_all(), do: read_status_histories_file()

  def find_by_id_enabled(id) do
    {:ok, current_status_histories} = read_status_histories_file()

    {:ok,
     current_status_histories
     |> Enum.find(fn %StatusHistory{id: status_history_id, status: status} ->
       status_history_id == id and status == Status.enable()
     end)}
  end

  def find_all_enabled() do
    {:ok, current_status_histories} = read_status_histories_file()

    {:ok,
     current_status_histories
     |> Enum.filter(fn %StatusHistory{status: status} -> status == Status.enable() end)}
  end

  def create(new_status_history = %StatusHistory{}) do
    {:ok, current_status_histories} = read_status_histories_file()
    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    status_history_id = GeneralUtils.generate_id("#{length(current_status_histories)}")

    new_status_history = %StatusHistory{
      new_status_history
      | id: status_history_id,
        status: Status.enable(),
        created_at: current_date_unix,
        updated_at: current_date_unix
    }

    updated_current_status_histories = [new_status_history | current_status_histories]

    case write_status_histories_file_content(updated_current_status_histories) do
      :ok -> {:ok, new_status_history}
      error -> error
    end
  end

  def update(id, updated_status_history = %StatusHistory{}) do
    {:ok, current_status_histories} = read_status_histories_file()

    existing_status_history =
      Enum.find(current_status_histories, fn %StatusHistory{id: status_history_id} ->
        status_history_id == id
      end)

    current_date_unix = DateTime.to_unix(DateTime.utc_now())

    updated_status_history = %StatusHistory{
      existing_status_history
      | model_id: Map.get(updated_status_history, :model_id, existing_status_history.model_id),
        model_type:
          Map.get(updated_status_history, :model_type, existing_status_history.model_type),
        parent_id: Map.get(updated_status_history, :parent_id, existing_status_history.parent_id),
        from_status:
          Map.get(updated_status_history, :from_status, existing_status_history.from_status),
        to_status: Map.get(updated_status_history, :to_status, existing_status_history.to_status),
        assigned_chef_id:
          Map.get(
            updated_status_history,
            :assigned_chef_id,
            existing_status_history.assigned_chef_id
          ),
        from_time: Map.get(updated_status_history, :from_time, existing_status_history.from_time),
        to_time: Map.get(updated_status_history, :to_time, existing_status_history.to_time),
        updated_at: current_date_unix
    }

    status_history_update_mapper = fn status_history ->
      case status_history.id == id do
        true ->
          updated_status_history

        false ->
          status_history
      end
    end

    updated_current_status_histories =
      current_status_histories |> Enum.map(status_history_update_mapper)

    case write_status_histories_file_content(updated_current_status_histories) do
      :ok -> {:ok, updated_status_history}
      error -> error
    end
  end

  def delete(id) do
    {:ok, current_status_histories} = read_status_histories_file()

    updated_current_status_histories =
      current_status_histories |> Enum.filter(fn status_history -> status_history.id != id end)

    case write_status_histories_file_content(updated_current_status_histories) do
      :ok -> {:ok, true}
      error -> error
    end
  end
end
