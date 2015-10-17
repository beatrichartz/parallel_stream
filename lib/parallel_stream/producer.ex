defmodule ParallelStream.Producer do
  def build!(stream, pipes) do
    num_pipes = pipes |> Enum.count

    stream
    |> Stream.chunk(num_pipes, num_pipes, [])
    |> Stream.transform fn -> 0 end, fn items, index ->
      mapped = items |> map_to_relay(index, pipes)

      { [mapped], index + num_pipes }
    end, fn index -> 
      pipes |> Enum.each fn { item_receiver, relay } ->
        relay |> send :halt
        item_receiver |> send { :halt, index }
      end
    end
  end

  defp map_to_relay(items, index, pipes) do
    num_pipes = pipes |> Enum.count

    items |> Stream.with_index |> Enum.map fn { item, i } -> 
      pipe_index = (index + i) |> rem(num_pipes)
      { item_receiver, relay } = pipes |> Enum.fetch!(pipe_index)
      item_receiver |> send({ index + i, item })

      { relay, index + i } 
    end
  end
end
