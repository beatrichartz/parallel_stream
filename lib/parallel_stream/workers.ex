defmodule ParallelStream.Workers do
  alias ParallelStream.Executor
  alias ParallelStream.Outqueue
  alias ParallelStream.Defaults

  def build!(num, fun, executor \\ Executor)
  def build!(nil, fun, executor) do
    build!(Defaults.num_workers, fun, executor)
  end
  def build!(num, fun, executor) when is_integer(num) do
    1..num |> Enum.map(fn _ ->
      self |> build!(fun, executor)
    end)
  end
  def build!(receiver, fun, executor) do
    { :ok, outqueue } = Task.start_link fn ->
      Outqueue.listen(receiver)
    end
    { :ok, inqueue } = Task.start_link fn ->
      executor.execute(fun)
    end

    { inqueue, outqueue }
  end
end
