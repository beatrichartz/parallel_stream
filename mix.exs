defmodule ParallelStream.Mixfile do
  use Mix.Project

  def project do
    [
      app: :parallel_stream,
      version: "1.1.0",
      elixir: "~> 1.5",
      deps: deps(),
      package: package(),
      docs: &docs/0,
      name: "Parallel Stream",
      consolidate_protocols: true,
      source_url: "https://github.com/beatrichartz/parallel_stream",
      description: "Parallel stream operations for Elixir",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test]
    ]
  end

  defp package do
    [
      maintainers: ["Beat Richartz"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/beatrichartz/parallel_stream"}
    ]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.5", only: :test},
      {:ex_doc, only: :dev},
      {:inch_ex, only: :dev},
      {:earmark, "1.4.15", only: :dev},
      {:benchfella, "~> 0.3.0", only: [:bench]}
    ]
  end

  defp docs do
    {ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])

    [
      source_ref: ref,
      main: "overview"
    ]
  end
end
