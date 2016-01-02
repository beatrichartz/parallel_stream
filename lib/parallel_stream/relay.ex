defmodule ParallelStream.Relay do
  def listen(receiver) do
    receive do
      :next ->
        receive do
          item ->
            send receiver, { self, item }
            receiver |> listen
        end
      :halt -> :halt #noop
    end
  end
end
