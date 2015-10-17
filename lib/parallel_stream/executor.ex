defmodule ParallelStream.Executor do
  @moduledoc ~S"""
  The executor - executes the function to be iterated on and sends it to the
  relay.
  """

  def execute(relay, fun) do
    receive do
      { :halt, _ } ->
        :ok
      { index, item } ->
        relay |> send({ index, fun.(item) })
        execute(relay, fun)
    end
  end
end
