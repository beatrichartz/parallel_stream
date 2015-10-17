defmodule ParallelStream.Executor do
  def execute(relay, fun) do
    receive do
      { :halt, _ } ->
        :ok
      { index, item } ->
        relay |> send({ index, fun.(item) })
        execute(relay, fun)
    end
  end
end
