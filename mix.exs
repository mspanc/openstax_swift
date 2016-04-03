defmodule OpenStax.Swift.Mixfile do
  use Mix.Project

  def project do
    [app: :openstax_swift,
     version: "0.1.0",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     description: "OpenStack Swift client",
     name: "OpenStax.Swift",
     source_url: "https://github.com/mspanc/openstax_swift",
     package: package,
     preferred_cli_env: [espec: :test],
     deps: deps]
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
      {:httpoison, "~> 0.8.2"},
      {:espec, "~> 0.8.17", only: :test}
    ]
  end


  defp package do
    [description: "OpenStack Swift client",
     files: ["lib",  "mix.exs", "README*"],
     maintainers: ["Marcin Lewandowski"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/mspanc/openstax_swift"}]
  end
end
