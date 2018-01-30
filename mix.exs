defmodule AbaCLI.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aba_cli,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:aba_model, :amqp, :amqp_client, :logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:aba_api, path: "../aba_api"},
      {:aba_model, path: "../aba_model"},
      {:amqp, "~> 1.0.0-pre.3"}
      # {:aba_api, git: "git@gitlab.com:jscheel42/aba_api.git", branch: "master"},
      # {:aba_model, git: "git@gitlab.com:jscheel42/aba_model.git", branch: "master"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
