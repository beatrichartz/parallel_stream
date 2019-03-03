defmodule ParallelStream.Each do
  alias ParallelStream.Producer

  @moduledoc ~S"""
  The each iterator implementation
  """

  defmodule Consumer do
    @moduledoc ~S"""
    The iterator consumer - receives stream values in order to
    drain stream
    """

    def build!(stream) do
      stream
      |> Stream.transform(0, fn items, acc ->
        items |> receive_from_outqueue

        {items, acc + 1}
      end)
    end

    defp receive_from_outqueue(items) do
      items
      |> Enum.each(fn {outqueue, index} ->
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
  parallel. The functions return value will be thrown away, hence this is
  useful for producing side-effects.

  ## Options

  These are the options:

    * `:num_workers`   – The number of parallel operations to run when running the stream.
    * `:worker_work_ratio` – The available work per worker, defaults to 5. Higher rates will mean more work sharing, but might also lead to work fragmentation slowing down the queues.

  ## Examples

  Iterate and write the numbers to stdout:

      iex> parallel_stream = 1..5 |> ParallelStream.each(&IO.write/1)
      iex> parallel_stream |> Stream.run
      :ok # 12345 appears on stdout
  """
  def each(stream, mapper, options \\ []) do
    stream
    |> Producer.build!(mapper, options)
    |> Consumer.build!()
  end
end
