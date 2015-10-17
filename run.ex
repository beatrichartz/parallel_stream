1..100
|> ParallelStream.map(fn item ->
  :timer.sleep(200)
  Integer.to_string(item)
end)
|> Enum.map(&IO.inspect/1)
