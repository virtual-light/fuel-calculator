defmodule FuelCalculator.MixProject do
  use Mix.Project

  def project do
    [
      app: :fuel_calculator,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      preferred_cli_env: preferred_cli_env()
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
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp dialyzer,
    do: [
      plt_add_apps: [:ex_unit]
    ]

  defp preferred_cli_env() do
    [credo: :test, dialyzer: :test]
  end
end
