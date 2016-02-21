defmodule ParallelStream.Producer do
  def build!(stream, inqueue, outqueues) do
    outqueue_count = outqueues |> Enum.count
    stream
    |> Stream.chunk(outqueue_count * 10, outqueue_count * 10, [])
    |> Stream.transform(fn -> 0 end, fn items, index ->
      mapped = items |> map_to_outqueue(index, inqueue, outqueues)

      { [mapped], index + outqueue_count * 10 }
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
