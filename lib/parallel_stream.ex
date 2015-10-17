defmodule ParallelStream do
  alias ParallelStream.Mapper
  alias ParallelStream.Each
  alias ParallelStream.Filter

  def map(stream, mapper, options \\ []) do
    Mapper.map(stream, mapper, options)
  end

  def each(stream, iter, options \\ []) do
    Each.each(stream, iter, options)
  end

  def filter(stream, filter, options \\ []) do
    Filter.filter(stream, filter, options)
  end

  def reject(stream, filter, options \\ []) do
    Filter.reject(stream, filter, options)
  end
end
