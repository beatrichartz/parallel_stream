defmodule ParallelStream.Producer do
  def build!(stream, pipes) do
    num_pipes = pipes |> Enum.count

    stream
    |> Stream.chunk(num_pipes, num_pipes, [])
    |> Stream.transform(fn -> 0 end, fn items, index ->
      mapped = items |> map_to_outqueue(index, pipes)

      { [mapped], index + num_pipes }
    end, fn index -> 
      pipes |> Enum.each(fn { inqueue, outqueue } ->
        outqueue |> send(:halt)
        inqueue |> send({ :halt, index })
      end)
    end)
  end

  defp map_to_outqueue(items, index, pipes) do
    num_pipes = pipes |> Enum.count

    items |> Stream.with_index |> Enum.map(fn { item, i } -> 
      pipe_index = (index + i) |> rem(num_pipes)
      { inqueue, outqueue } = pipes |> Enum.fetch!(pipe_index)
      inqueue |> send({ index + i, item, outqueue })

      { outqueue, index + i } 
    end)
  end
end

# item > inqueue > workers > outqueue > pick
