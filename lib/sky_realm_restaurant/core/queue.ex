defmodule SkyRealmRestaurant.Core.Queue do
  @derive Jason.Encoder

  @q_path "in_memory_store"

  @attrs capacity: nil, items: [], name: nil

  defstruct @attrs

  alias SkyRealmRestaurant.Core.Queue
  alias SkyRealmRestaurant.Utils.FileUtils

  def get_attrs, do: @attrs

  defp read_queue_file(q_name),
    do: FileUtils.read_queue_from_file("#{@q_path}/#{q_name}.txt", Queue)

  defp write_queue_file_content(queue = %Queue{name: q_name}),
    do: FileUtils.write_queue_to_file("#{@q_path}/#{q_name}.txt", queue)

  def init_queue(q_name, q_capacity) do
    new_queue = %Queue{capacity: q_capacity, name: q_name, items: []}

    case write_queue_file_content(new_queue) do
      :ok -> {:ok, new_queue}
      error -> error
    end
  end

  def init_multiple_queues([], _q_capacity), do: :ok

  def init_multiple_queues([q_name | q_names], q_capacity) do
    case init_queue(q_name, q_capacity) do
      {:ok, _} -> init_multiple_queues(q_names, q_capacity)
      error -> error
    end
  end

  def get_by_queue_name(q_name), do: read_queue_file(q_name)

  def enqueue_by_queue_name(q_name, item) do
    {:ok, queue} = get_by_queue_name(q_name)
    {:ok, updated_queue} = enqueue(item, queue)

    case write_queue_file_content(updated_queue) do
      :ok -> {:ok, updated_queue}
      error -> error
    end
  end

  def enqueue(item, queue = %Queue{items: q_items, capacity: q_capacity}) do
    case q_capacity > length(q_items) do
      true ->
        {:ok, %Queue{queue | items: [item | q_items]}}

      false ->
        {:error, "Queue met its max. capacity"}
    end
  end

  def dequeue_by_queue_name(q_name) do
    {:ok, queue} = get_by_queue_name(q_name)

    {result, dq_item, updated_queue} = dequeue(queue)

    case write_queue_file_content(updated_queue) do
      :ok -> {result, dq_item, updated_queue}
      error -> error
    end
  end

  def dequeue(queue = %Queue{items: []}), do: {:ok, nil, queue}

  def dequeue(queue = %Queue{items: [q_item | []]}), do: {:ok, q_item, %Queue{queue | items: []}}

  def dequeue(queue = %Queue{items: [q_item | q_items]}) do
    {result, dq_item, updated_queue} = dequeue(%Queue{queue | items: q_items})
    {result, dq_item, %Queue{updated_queue | items: [q_item | updated_queue.items]}}
  end
end
