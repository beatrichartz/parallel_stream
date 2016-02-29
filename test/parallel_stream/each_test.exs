defmodule ParallelStream.EachTest do
  use ExUnit.Case, async: true
  @moduletag timeout: 100

  setup do
    # :observer.start

    :ok
  end

  defmodule TestReceiver do
    def rec(received \\ []) do
      receive do
        :stop ->
          received
        i ->
          rec(received ++ [i]) 
      end
    end
  end

  test ".each iterates over a stream of variable length" do
    testmod = self

    1..5
    |> ParallelStream.each(fn i -> 
      send testmod, i
    end)
    |> Stream.run

    send self, :stop

    assert TestReceiver.rec |> Enum.sort == [1, 2, 3, 4, 5]
  end

  test ".each iterates over a stream of zero length" do
    testmod = self

    []
    |> ParallelStream.each(fn i -> 
      send testmod, i
    end)
    |> Stream.run

    send self, :stop

    assert TestReceiver.rec == []
  end

  test ".each does propagate errors via links" do
    trap = Process.flag(:trap_exit, true)
    pid = spawn_link fn ->
      [1,2]
        |> ParallelStream.each(fn i -> 
          if i |> rem(2) == 0 do
            raise RuntimeError
          end
        end)
        |> Enum.into([])
    end

    assert_receive { :EXIT, ^pid, { %RuntimeError{}, _ } }

    Process.exit(pid, :kill)
    refute Process.alive?(pid)

    Process.flag(:trap_exit, trap)
  end

  test ".each parallelizes the iteration function" do
    { microseconds, :ok } = :timer.tc fn ->
      1..5
      |> ParallelStream.each(fn _ -> :timer.sleep(10) end)
      |> Stream.run
    end

    assert microseconds < 50000
  end

  test ".each parallelizes the iteration function with the number of parallel streams defined" do
    { microseconds, :ok } = :timer.tc fn ->
      1..12
      |> ParallelStream.each(fn _ -> :timer.sleep(10) end, num_workers: 12)
      |> Stream.run
    end

    assert microseconds < 120000
  end

  test ".each parallelizes the iteration function with work sharing" do
    { microseconds, :ok } = :timer.tc fn ->
      1..500
      |> ParallelStream.each(fn i ->
        if rem(i,20) == 10 do
          :timer.sleep(10)
        else
          :timer.sleep(1)
        end
      end, num_workers: 50)
      |> Stream.run
    end

    assert microseconds < 100000
  end

end
