defmodule Bench do
  use Benchfella
  Benchfella.start

  setup_all do
    if System.get_env("PS_BENCH_OBSERVER") do
      :observer.start()
    end

    { :ok, nil }
  end

  bench "stream" do
    1..10000
    |> Stream.map(fn _ ->
      :timer.sleep(1)
    end)
    |> Stream.run
  end

  bench "parallel_stream" do
    1..10000
    |> ParallelStream.map(fn _ ->
      :timer.sleep(1)
    end)
    |> Stream.run
  end
end
