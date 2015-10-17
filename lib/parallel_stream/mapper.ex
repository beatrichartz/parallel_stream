defmodule ParallelStream.Mapper do
  alias ParallelStream.Pipes
  alias ParallelStream.Producer

  @moduledoc ~S"""
  The map iterator implementation
  """

  use ParallelStream.Defaults

  defmodule Consumer do
    @moduledoc ~S"""
    The mapper - receives mapped stream values and returns them to the
    stream
    """

    def build!(stream) do
      stream |> Stream.transform 0, fn items, acc ->
        mapped = items |> receive_from_relay

        { mapped, acc + 1 }
      end
    end

    defp receive_from_relay(items) do
      items |> Enum.map fn { relay, index } ->
        relay |> send :next
        receive do
          { ^relay, { ^index, item } } ->
            item
        end
      end
    end
  end

  @doc """
  Creates a stream that will apply the given function on enumeration in
  parallel and return the functions return value.

  ## Options

  These are the options:

    * `:num_pipes`   – The number of parallel operations to run when running the stream.

  ## Examples

  Map and duplicate the numbers:

      iex> parallel_stream = 1..5 |> ParallelStream.map(fn i -> i * 2 end)
      iex> parallel_stream |> Enum.to_list
      [2, 4, 6, 8, 10]
  """
  def map(stream, mapper, options \\ []) do
    pipes = options
            |> Keyword.get(:num_pipes, @num_pipes)
            |> Pipes.build!(mapper)

    stream |> Producer.build!(pipes) 
           |> Consumer.build!
  end

end
