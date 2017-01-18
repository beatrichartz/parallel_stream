defmodule ParallelStream.RejectTest do
  use ExUnit.Case, async: true
  @moduletag timeout: 1000

  test ".reject filters a stream of variable length" do
    result = 1..5
              |> ParallelStream.reject(fn i -> i |> rem(2) == 0 end)
              |> Enum.into([])

    assert result == [1, 3, 5]
  end

  test ".reject kills all processes after it is done" do
    { :links, links_before } = Process.info(self(), :links)

    1..5
      |> ParallelStream.reject(fn i -> i |> rem(2) == 0 end)
      |> Enum.into([])

    :timer.sleep(10)
    { :links, links_after } = Process.info(self(), :links)

    assert links_before == links_after
  end

  test ".reject is repeatable" do
    stream = 1..5
              |> ParallelStream.reject(fn i -> i |> rem(2) == 0 end)

    result1 = stream |> Enum.into([])
    assert result1 == [1, 3, 5]

    result2 = stream |> Enum.into([])
    assert result2 == [1, 3, 5]
  end

  test ".reject filters a stream of zero length" do
    result = []
              |> ParallelStream.filter(fn i -> i |> rem(2) == 0 end)
              |> Enum.into([])

    assert result == []
  end

  test ".reject does propagate errors via links" do
    trap = Process.flag(:trap_exit, true)
    pid = spawn_link fn ->
      [1,2]
        |> ParallelStream.filter(fn i -> 
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

  test ".reject rejects the stream in order" do
    result = 1..1000
              |> ParallelStream.reject(fn i -> i |> rem(2) == 0 end)
              |> Enum.into([])

    assert result == 1..1000 |> Enum.reject(fn i -> i |> rem(2) == 0 end)
  end

  test ".reject parallelizes the filter function" do
    { microseconds, :ok } = :timer.tc fn ->
      1..5
      |> ParallelStream.reject(fn _ -> :timer.sleep(10) end)
      |> Stream.run
    end

    assert microseconds < 50000
  end

  test ".reject parallelizes the filter function with the number of parallel streams defined" do
    { microseconds, :ok } = :timer.tc fn ->
      1..12
      |> ParallelStream.reject(fn _ -> :timer.sleep(10) end, num_workers: 12)
      |> Stream.run
    end

    assert microseconds < 120000
  end

  test ".reject parallelizes the filter function with work sharing" do
    { microseconds, :ok } = :timer.tc fn ->
      1..500
      |> ParallelStream.reject(fn i ->
        if rem(i,20) == 10 do
          :timer.sleep(10)
          false
        else
          :timer.sleep(1)
          true
        end
      end, num_workers: 50)
      |> Stream.run
    end

    assert microseconds < 100000
  end

end
