defmodule ParallelStream.Filter do
  alias ParallelStream.FilterExecutor
  alias ParallelStream.Pipes
  alias ParallelStream.Producer

  use ParallelStream.Defaults

  defmodule Consumer do
    def build!(stream, direction) do
      stream |> Stream.transform 0, fn items, acc ->
        filtered = items |> Enum.reduce([], fn { relay, index }, list ->
          relay |> send :next
          receive do
            { ^relay, { ^index, accepted, item } } ->
              case !!accepted do
                ^direction -> list ++ [item]
                _ -> list
              end
          end
        end)

        { filtered, acc + 1 }
      end
    end
  end

  def filter(stream, mapper, options \\ []) do
    pipes = options
            |> Keyword.get(:num_pipes, @num_pipes)
            |> Pipes.build!(mapper, FilterExecutor)

    stream |> Producer.build!(pipes) 
           |> Consumer.build!(true)
  end

  def reject(stream, mapper, options \\ []) do
    pipes = options
            |> Keyword.get(:num_pipes, @num_pipes)
            |> Pipes.build!(mapper, FilterExecutor)

    stream |> Producer.build!(pipes) 
           |> Consumer.build!(false)
  end


end
