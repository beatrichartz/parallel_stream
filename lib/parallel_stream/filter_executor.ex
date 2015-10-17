defmodule ParallelStream.FilterExecutor do
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
