defmodule ParallelStream.Outqueue do
  def collect(receiver) do
    receive do
      { :next, index } ->
        receive do
          { ^index, item } ->
            send receiver, { self, { index, item } }
            receiver |> collect
          { ^index, accept, item } ->
            send receiver, { self, { index, accept, item } }
            receiver |> collect
        end
      :halt -> :ok #noop
    end
  end
end
