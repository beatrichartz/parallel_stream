defmodule ParallelStream.Producer do
  alias ParallelStream.Defaults
  alias ParallelStream.Workers
  alias ParallelStream.Executor

  def build!(stream, fun, options) do
    build!(stream, fun, Executor, options)
  end

  def build!(stream, fun, executor, options) do
    worker_work_ratio = options |> Keyword.get(:worker_work_ratio, Defaults.worker_work_ratio())
    worker_count = options |> Keyword.get(:num_workers, Defaults.num_workers())
    chunk_size = worker_count * worker_work_ratio

    stream
    |> Stream.chunk_every(chunk_size, chunk_size, [])
    |> Stream.transform(
      fn ->
        {
          inqueue,
          workers,
          outqueues
        } = worker_count |> Workers.build!(fun, executor)

        {inqueue, workers, outqueues, 0}
      end,
      fn items, {inqueue, workers, outqueues, index} ->
        mapped =
          items
          |> Stream.with_index()
          |> Enum.map(fn {item, i} ->
            outqueue = outqueues |> Enum.at(rem(i, worker_count))
            inqueue |> send({index + i, item, outqueue})

            {outqueue, index + i}
          end)

        {[mapped], {inqueue, workers, outqueues, index + chunk_size}}
      end,
      fn {inqueue, workers, outqueues, _} ->
        inqueue |> send(:halt)
        outqueues |> Enum.each(fn outqueue -> outqueue |> send(:halt) end)
        workers |> Enum.each(fn worker -> worker |> send(:halt) end)
      end
    )
  end
end
