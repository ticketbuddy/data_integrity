defmodule DataIntegrity.MixProject do
  use Mix.Project

  def project do
    [
      app: :data_integrity,
      version: "0.1.0",
      elixir: "~> 1.9",
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
      {:crimpex, git: "https://github.com/BBC-News/crimpex.git"}
    ]
  end
end