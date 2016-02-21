defmodule ParallelStream.Inqueue do
  def distribute do
    receive do
      { :next, worker } ->
        receive do
          { index, item, outqueue } ->
            send worker, { index, item, outqueue }
            distribute
        end
      :halt -> :ok #noop
    end
  end
end
