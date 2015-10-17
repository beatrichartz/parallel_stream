defmodule ParallelStream.Defaults do
  @moduledoc ~S"""
  The default options for parallel streams
  """

  defmacro __using__(_) do
    num_schedulers = :erlang.system_info(:schedulers) * 2

    quote do
      @num_pipes unquote(num_schedulers)
    end
  end
end
