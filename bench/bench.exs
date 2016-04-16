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
      :erlang.md5(:crypto.strong_rand_bytes(32))
    end)
    |> Stream.run
  end

  bench "parallel_stream" do
    1..10000
    |> ParallelStream.map(fn _ ->
      :erlang.md5(:crypto.strong_rand_bytes(32))
    end)
    |> Stream.run
  end
end
