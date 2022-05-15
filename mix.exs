defmodule Weather.MixProject do
  use Mix.Project

  def project do
    [
      app: :weather,
      escript: [main_module: Weather.CLI],
      version: "1.0.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      { :httpoison, "~> 1.8.1" }
    ]
  end
end
