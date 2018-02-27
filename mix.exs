defmodule AbaCLI.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aba_cli,
      version: "1.0.0",
      elixir: "~> 1.6",
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
      # {:aba_api, path: "../aba_api"},
      # {:aba_model, path: "../aba_model"},
      {:aba_api, git: "https://github.com/jscheel42/aba_api.git", branch: "master"},
      {:aba_model, git: "https://github.com/jscheel42/aba_model.git", branch: "master"},
      # {:amqp, "~> 1.0.0-pre.3"}
      # {:aba_api, git: "git@gitlab.com:jscheel42/aba_api.git", branch: "master"},
      # {:aba_model, git: "git@gitlab.com:jscheel42/aba_model.git", branch: "master"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
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
