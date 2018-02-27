defmodule AbaCLI.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aba_cli,
      version: "1.0.0",
      elixir: "~> 1.6",
      name: "AbaCLI",
      description: "AbaCLI is a tool to update data in an AbaModel database.",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:aba_model, :logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      { :ex_doc, "~> 0.18", only: :dev },
      # {:aba_api, path: "../aba_api"},
      # {:aba_model, path: "../aba_model"},
      {:aba_api, "~> 1.0"},
      {:aba_model, "~> 1.0"},
    ]
  end

  defp docs do
    [
      main: "AbaCLI",
      extras: ["README.md"],
      output: ["docs"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Joshua Scheel"],
      links: %{"Github": "https://github.com/jscheel42/aba_cli",
               "TravisCI": "https://travis-ci.org/jscheel42/aba_cli"}
    ]
  end
end
