# ParallelStream [![Build Status](https://travis-ci.org/beatrichartz/parallel_stream.svg?branch=master)](https://travis-ci.org/beatrichartz/parallel_stream) [![Inline docs](http://inch-ci.org/github/beatrichartz/parallel_stream.svg?branch=master)](http://inch-ci.org/github/beatrichartz/parallel_stream)
Parallelized stream implementation for elixir

## What does it do?

Parallelize some stream operations in Elixir whilst keeping your stream in order.

## How do I get it?

Add
```elixir
{:parallel_stream, "~> 0.1.0"}
```
to your deps in `mix.exs` like so:

```elixir
defp deps do
  [
    {:parallel_stream, "~> 0.1.0"}
  ]
end
```

Note: Elixir `1.1.0` is required

## How to use

Do this to parallelize a map:

````elixir
1..100 |> ParallelStream.map(fn i -> i * 2 end)
````

And you'll get a stream of mapped values which you can then for example `Enum.into([])`.

More supported functions are `each`:

````elixir
1..100 |> ParallelStream.each(&IO.inspect/1)
````

`filter`:

````elixir
1..100 |> ParallelStream.filter(fn i -> i |> rem(2) == 0 end)
````

and `filter`'s counterpart, `reject`:

````elixir
1..100 |> ParallelStream.reject(fn i -> i |> rem(2) == 0 end)
````

## License

MIT

## Contributions & Bugfixes are most welcome!
