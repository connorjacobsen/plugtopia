defmodule Plugtopia.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plugtopia,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Plugtopia.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.4.3"},
      {:ecto, "~> 2.1.6"},
      {:sqlite_ecto2, "~> 2.0"}
    ]
  end
end
