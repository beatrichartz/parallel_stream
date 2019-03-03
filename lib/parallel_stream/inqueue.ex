defmodule ParallelStream.Inqueue do
  def distribute do
    receive do
      {:next, worker} ->
        receive do
          {index, item, outqueue} ->
            send(worker, {index, item, outqueue})
            distribute()

          :halt ->
            :halt
        end

      :halt ->
        # noop
        :halt
    end
  end
end
