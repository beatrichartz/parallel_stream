defmodule ParallelStream do
  alias ParallelStream.Mapper
  alias ParallelStream.Each
  alias ParallelStream.Filter

  @moduledoc ~S"""
  Parallel stream implementation for Elixir.
  """

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
    Mapper.map(stream, mapper, options)
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
  def each(stream, iter, options \\ []) do
    Each.each(stream, iter, options)
  end

  @doc """
  Creates a stream that will apply the given function on enumeration in
  parallel and only pass the values for which the function returns truthy
  downstream.

  ## Options

  These are the options:

    * `:num_workers`   – The number of parallel operations to run when running the stream.
    * `:worker_work_ratio` – The available work per worker, defaults to 5. Higher rates will mean more work sharing, but might also lead to work fragmentation slowing down the queues.

  ## Examples

  Map and filter the even numbers:

      iex> parallel_stream = 1..5 |> ParallelStream.filter(fn i -> i |> rem(2) == 0 end)
      iex> parallel_stream |> Enum.to_list
      [2,4]
  """
  def filter(stream, filter, options \\ []) do
    Filter.filter(stream, filter, options)
  end

  @doc """
  Creates a stream that will apply the given function on enumeration in
  parallel and only pass the values for which the function returns falsy
  downstream.

  ## Options

  These are the options:

    * `:num_workers`       – The number of parallel operations to run when running the stream.
    * `:worker_work_ratio` – The available work per worker, defaults to 5. Higher rates will mean more work sharing, but might also lead to work fragmentation slowing down the queues.

  ## Examples

  Map and reject the even numbers:

      iex> parallel_stream = 1..5 |> ParallelStream.reject(fn i -> i |> rem(2) == 0 end)
      iex> parallel_stream |> Enum.to_list
      [1,3,5]
  """
  def reject(stream, filter, options \\ []) do
    Filter.reject(stream, filter, options)
  end
end
