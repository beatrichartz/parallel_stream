defmodule ParallelStream.Workers do
  alias ParallelStream.Executor
  alias ParallelStream.Outqueue
  alias ParallelStream.Inqueue
  alias ParallelStream.Defaults

  defmodule Worker do
    def work(inqueue, executor, fun) do
      send inqueue, { :next, self }
      executor.execute(fun)
      work(inqueue, executor, fun)
    end
  end

  def build!(num, fun, executor \\ Executor)
  def build!(nil, fun, executor) do
    build!(Defaults.num_workers, fun, executor)
  end
  def build!(num, fun, executor) when is_integer(num) do
    { :ok, inqueue } = Task.start_link fn ->
      Inqueue.distribute
    end

    receiver = self

    1..num |> Enum.map(fn _ ->
      { :ok, outqueue } = Task.start_link fn ->
        Outqueue.listen(receiver)
      end
      { :ok, worker } = Task.start_link fn ->
        Worker.work(inqueue, executor, fun)
      end

      { inqueue, outqueue }
    end)
  end

end

