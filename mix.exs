defmodule Pylon.Mixfile do
  use Mix.Project

  def project do
    [app: :pylon,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [ mod: { Pylon, [] },
      applications: [:cowboy, :httpoison, :crypto] ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:cowboy, git: "https://github.com/ninenines/cowboy", tag: "1.0.3"},
      {:httpoison, "~> 0.7.2"},
      {:exredis, ">= 0.2.2"},
      {:ejwt, git: "https://github.com/kato-im/ejwt"}
    ]
  end
end