defmodule OpenStax.Swift.Mixfile do
  use Mix.Project

  def project do
    [app: :openstax_swift,
     version: "0.3.0",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     description: "OpenStack Swift client",
     maintainers: ["Marcin Lewandowski"],
     licenses: ["MIT"],
     name: "OpenStax.Swift",
     source_url: "https://github.com/mspanc/openstax_swift",
     package: package(),
     preferred_cli_env: [espec: :test],
     deps: deps()]
  end


  def application do
    [applications: [:crypto, :httpoison],
     mod: {OpenStax.Swift, []}]
  end


  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib",]


  defp deps do
    deps(:test_dev)
  end


  defp deps(:test_dev) do
    [
      {:httpoison, "~> 0.10"},
      {:poison, "~> 2.0"},

      {:espec, "~> 1.1", only: :test},
      {:excoveralls, "~> 0.6",  only: :test},

      {:ex_doc, "~> 0.14", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev}
    ]
  end


  defp package do
    [description: "OpenStack Swift client",
     files: ["lib",  "mix.exs", "README*", "LICENSE"],
     maintainers: ["Marcin Lewandowski"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/mspanc/openstax_swift"}]
  end
end
