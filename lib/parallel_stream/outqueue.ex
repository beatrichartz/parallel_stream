defmodule ParallelStream.Outqueue do
  def collect(receiver) do
    receive do
      {:next, index} ->
        receive do
          {^index, item} ->
            send(receiver, {self(), {index, item}})
            receiver |> collect

          {^index, accept, item} ->
            send(receiver, {self(), {index, accept, item}})
            receiver |> collect
        end

      # noop
      :halt ->
        :ok
    end
  end
end
