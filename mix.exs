defmodule LogsnagEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :logsnag_ex,
      version: "1.0.1",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      name: "LogsnagEx",
      description: "Logsnag client for Elixir",
      source_url: "https://github.com/chrisgreg/logsnag_ex",
      docs: [
        main: "LogsnagEx",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      name: "logsnag_ex",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/chrisgreg/logsnag_ex"}
    ]
  end

  defp deps do
    [
      {:req, "~> 0.4"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:mox, "~> 1.0", only: :test}
    ]
  end
end
