defmodule ParallelStream.Producer do
  alias ParallelStream.Defaults

  def build!(stream, inqueue, outqueues, options) do
    worker_work_ratio = options |> Keyword.get(:worker_work_ratio, Defaults.worker_work_ratio)
    worker_count = outqueues |> Enum.count
    chunk_size = worker_count * worker_work_ratio

    stream
    |> Stream.chunk(chunk_size, chunk_size, [])
    |> Stream.transform(fn -> 0 end, fn items, index ->
      mapped = items |> map_to_outqueue(index, inqueue, outqueues)

      { [mapped], index + chunk_size }
    end, fn index ->
      inqueue |> send(:halt)
    end)
  end

  defp map_to_outqueue(items, index, inqueue, outqueues) do
    outqueue_count = outqueues |> Enum.count

    items |> Stream.with_index |> Enum.map(fn { item, i } -> 
      outqueue = outqueues |> Enum.at(rem(i, outqueue_count))
      inqueue |> send({ index + i, item, outqueue })

      { outqueue, index + i }
    end)
  end
end

# item > inqueue > workers > outqueue > pick
