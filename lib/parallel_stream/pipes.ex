defmodule ParallelStream.Pipes do
  alias ParallelStream.Executor
  alias ParallelStream.Relay
  alias ParallelStream.Defaults

  def build!(num, fun, executor \\ Executor)
  def build!(nil, fun, executor) do
    build!(Defaults.num_pipes, fun, executor)
  end
  def build!(num, fun, executor) when is_integer(num) do
    1..num |> Enum.map(fn _ ->
      self |> build!(fun, executor)
    end)
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
