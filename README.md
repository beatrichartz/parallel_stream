# ParallelStream [![Build Status](https://app.travis-ci.com/beatrichartz/parallel_stream.svg?branch=master)](https://app.travis-ci.com/beatrichartz/parallel_stream) [![Coverage Status](https://coveralls.io/repos/github/beatrichartz/parallel_stream/badge.svg?branch=master)](https://coveralls.io/github/beatrichartz/parallel_stream?branch=master) [![Inline docs](http://inch-ci.org/github/beatrichartz/parallel_stream.svg?branch=master)](http://inch-ci.org/github/beatrichartz/parallel_stream) [![Hex pm](http://img.shields.io/hexpm/v/parallel_stream.svg?style=flat)](https://hex.pm/packages/parallel_stream) [![Downloads](https://img.shields.io/hexpm/dw/parallel_stream.svg?style=flat)](https://hex.pm/packages/parallel_stream)
Parallelized stream implementation for elixir

## What does it do?

Parallelize some stream operations in Elixir whilst keeping your stream in order.
Operates with a worker pool.

## How do I get it?

Add
```elixir
{:parallel_stream, "~> 1.0.5"}
```
to your deps in `mix.exs` like so:

```elixir
defp deps do
  [
    {:parallel_stream, "~> 1.0.5"}
  ]
end
```

Note: Elixir `1.1.0` is required

## How to use

Do this to parallelize a `map`:

````elixir
stream = 1..10 |> ParallelStream.map(fn i -> i * 2 end)
stream |> Enum.into([])
[2,4,6,8,10,12,14,16,18,20]
````

The generated stream is sorted the same as the input stream. 

More supported functions are `each` (to produce side-effects):

````elixir
1..100 |> ParallelStream.each(&IO.inspect/1)
````

`filter`:

````elixir
stream = 1..20 |> ParallelStream.filter(fn i -> i |> rem(2) == 0 end)
stream |> Enum.into([])
[2,4,6,8,10,12,14,16,18,20]
````

and `filter`'s counterpart, `reject`:

````elixir
stream = 1..20 |> ParallelStream.reject(fn i -> i |> rem(2) == 0 end)
stream |> Enum.into([])
[1,3,5,7,9,11,13,15,17,19]
````

## License

MIT

## Contributions & Bugfixes are most welcome!
