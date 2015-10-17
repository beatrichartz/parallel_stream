defmodule ParallelStream.FilterExecutor do
  @moduledoc ~S"""
  The filter executor - in addition to the normal executors return values,
  returns the value itself and the predicate
  """
  def execute(relay, fun) do
    receive do
      { :halt, _ } ->
        :ok
      { index, item } ->
        relay |> send({ index, fun.(item), item })
        execute(relay, fun)
    end
  end
end
