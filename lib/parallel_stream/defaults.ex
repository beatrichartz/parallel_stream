defmodule ParallelStream.Defaults do
  def num_workers do
    :erlang.system_info(:schedulers) * 2
  end
end
