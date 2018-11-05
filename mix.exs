defmodule Elixircom.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixircom,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      description: description()
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
      {:nerves_uart, "~> 1.2"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp docs() do
    [
      main: "readme",
      extras: [
        "README.md"
      ],
      source_url: "https://github.com/mattludwigs/elixircom"
    ]
  end

  defp package do
    [
      maintainers: ["Matt Ludwigs"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/mattludwigs/elixircom"}
    ]
  end

  defp description do
    "Serial device terminal emulator for Elixir to be ran inside of IEx"
  end
end
