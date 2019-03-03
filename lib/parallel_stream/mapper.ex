defmodule ParallelStream.Mapper do
  alias ParallelStream.Producer

  @moduledoc ~S"""
  The map iterator implementation
  """

  defmodule Consumer do
    @moduledoc ~S"""
    The mapper - receives mapped stream values and returns them to the
    stream
    """

    def build!(stream) do
      stream
      |> Stream.transform(0, fn items, acc ->
        mapped = items |> receive_from_outqueue

        {mapped, acc + 1}
      end)
    end

    defp receive_from_outqueue(items) do
      items
      |> Enum.map(fn {outqueue, index} ->
        outqueue |> send({:next, index})

        receive do
          {^outqueue, {^index, item}} ->
            item
        end
      end)
    end
  end

  @doc """
  Creates a stream that will apply the given function on enumeration in
  parallel and return the functions return value.

  ## Options

  These are the options:

    * `:num_workers`   – The number of parallel operations to run when running the stream.
    * `:worker_work_ratio` – The available work per worker, defaults to 5. Higher rates will mean more work sharing, but might also lead to work fragmentation slowing down the queues.

  ## Examples

  Map and duplicate the numbers:

      iex> parallel_stream = 1..5 |> ParallelStream.map(fn i -> i * 2 end)
      iex> parallel_stream |> Enum.to_list
      [2, 4, 6, 8, 10]
  """
  def map(stream, mapper, options \\ []) do
    stream
    |> Producer.build!(mapper, options)
    |> Consumer.build!()
  end
end
