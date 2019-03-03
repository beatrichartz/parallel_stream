defmodule ParallelStream.Workers do
  alias ParallelStream.Outqueue
  alias ParallelStream.Inqueue

  defmodule Worker do
    def work(inqueue, executor, fun) do
      send(inqueue, {:next, self()})

      case executor.execute(fun) do
        :ok ->
          work(inqueue, executor, fun)

        :halt ->
          :halt
      end
    end
  end

  def build!(num, fun, executor) when is_integer(num) do
    {:ok, inqueue} =
      Task.start_link(fn ->
        Inqueue.distribute()
      end)

    receiver = self()

    outqueues =
      1..num
      |> Enum.map(fn _ ->
        {:ok, outqueue} =
          Task.start_link(fn ->
            Outqueue.collect(receiver)
          end)

        outqueue
      end)

    workers =
      1..num
      |> Enum.map(fn _ ->
        {:ok, worker} =
          Task.start_link(fn ->
            Worker.work(inqueue, executor, fun)
          end)

        worker
      end)

    {inqueue, workers, outqueues}
  end
end
