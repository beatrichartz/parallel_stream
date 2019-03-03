defmodule ParallelStream.Executor do
  @moduledoc ~S"""
  The executor - executes the function to be iterated on and sends it to the
  relay.
  """

  def execute(fun) do
    receive do
      :halt ->
        :halt

      {index, item, outqueue} ->
        outqueue |> send({index, fun.(item)})
        :ok
    end
  end
end
