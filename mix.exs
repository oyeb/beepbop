defmodule BeepBop.MixProject do
  use Mix.Project

  def project do
    [
      app: :beepbop,
      version: "0.0.1",
      elixir: "~> 1.6",
      description: description(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ok, "~> 1.9"},
      {:excoveralls, "~> 0.7", only: :test},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "State Machine DSL for elixir. Could be useful, maybe."
  end
end
