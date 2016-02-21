defmodule ParallelStream.Outqueue do
  def collect(receiver) do
    receive do
      :next ->
        receive do
          item ->
            send receiver, { self, item }
            receiver |> collect
        end
      :halt -> :halt #noop
    end
  end
end
