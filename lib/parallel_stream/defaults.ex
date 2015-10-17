defmodule ParallelStream.Defaults do
  defmacro __using__(_) do
    num_schedulers = :erlang.system_info(:schedulers) * 2

    quote do
      @num_pipes unquote(num_schedulers)
    end
  end
end
