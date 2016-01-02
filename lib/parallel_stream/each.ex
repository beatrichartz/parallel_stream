defmodule ParallelStream.Each do
  alias ParallelStream.Pipes
  alias ParallelStream.Producer

  @moduledoc ~S"""
  The each iterator implementation
  """

  use ParallelStream.Defaults

  defmodule Consumer do
    @moduledoc ~S"""
    The iterator consumer - receives stream values in order to
    drain stream
    """

    def build!(stream) do
      stream |> Stream.transform(0, fn items, acc ->
        items |> receive_from_relay

        { items, acc + 1 }
      end)
    end

    defp receive_from_relay(items) do
      items |> Enum.each(fn { relay, index } ->
        relay |> send(:next)
        receive do
          { ^relay, { ^index, item } } ->
            item
        end
      end)
    end
  end

  @doc """
  Creates a stream that will apply the given function on enumeration in
  parallel. The functions return value will be thrown away, hence this is
  useful for producing side-effects.

  ## Options

  These are the options:

    * `:num_pipes`   – The number of parallel operations to run when running the stream.

  ## Examples

  Iterate and write the numbers to stdout:

      iex> parallel_stream = 1..5 |> ParallelStream.each(&IO.write/1)
      iex> parallel_stream |> Enum.to_list
      12345
      [1,2,3,4,5]
  """
  def each(stream, mapper, options \\ []) do
    pipes = options
            |> Keyword.get(:num_pipes, @num_pipes)
            |> Pipes.build!(mapper)

    stream |> Producer.build!(pipes) 
           |> Consumer.build!
  end
end
