defmodule Toast.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/dmkenney/toast"

  def project do
    [
      app: :toast,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package(),
      name: "Toast",
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 0.20 or ~> 1.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Server-rendered toast notifications for Phoenix LiveView.
    """
  end

  defp package do
    [
      name: "toast",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      files: ~w(lib assets .formatter.exs mix.exs README.md LICENSE),
      maintainers: ["Dylan Kenney"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
