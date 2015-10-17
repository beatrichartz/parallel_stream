defmodule ParallelStream.Pipes do
  alias ParallelStream.Executor
  alias ParallelStream.Relay

  def build!(num, fun, executor \\ Executor)
  def build!(num, fun, executor) when is_integer(num) do
    1..num |> Enum.map fn _ ->
      self |> build!(fun, executor)
    end
  end
  def build!(receiver, fun, executor) do
    { :ok, relay } = Task.start_link fn ->
      Relay.listen(receiver) 
    end
    { :ok, item_receiver } = Task.start_link fn ->
      executor.execute(relay, fun)
    end

    { item_receiver, relay }
  end
end
