defmodule ParallelStream.FilterExecutor do
  @moduledoc ~S"""
  The filter executor - in addition to the normal executors return values,
  returns the value itself and the predicate
  """
  def execute(fun) do
    receive do
      :halt ->
        :ok
      { index, item, outqueue } ->
        outqueue |> send({ index, fun.(item), item })
    end
  end
end
