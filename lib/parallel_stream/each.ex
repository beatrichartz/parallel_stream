defmodule ParallelStream.Each do
  alias ParallelStream.Pipes
  alias ParallelStream.Producer

  use ParallelStream.Defaults

  defmodule Consumer do
    def build!(stream) do
      stream |> Stream.transform 0, fn items, acc ->
        items |> receive_from_relay

        { items, acc + 1 }
      end
    end

    defp receive_from_relay(items) do
      items |> Enum.each fn { relay, index } ->
        relay |> send :next
        receive do
          { ^relay, { ^index, item } } ->
            item
        end
      end
    end
  end

  def each(stream, mapper, options \\ []) do
    pipes = options
            |> Keyword.get(:num_pipes, @num_pipes)
            |> Pipes.build!(mapper)

    stream |> Producer.build!(pipes) 
           |> Consumer.build!
  end
end
