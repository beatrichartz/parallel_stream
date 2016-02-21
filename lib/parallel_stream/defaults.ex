defmodule ParallelStream.Defaults do
  def num_pipes do
    :erlang.system_info(:schedulers) * 2
  end
end
