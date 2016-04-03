defmodule OpenStax.Swift do
  use Application


  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # worker(OpenStax.Swift.AuthCache, [[name: OpenStax.Swift.AuthCache]])
    ]

    opts = [strategy: :one_for_one, name: OpenStax.Swift]
    Supervisor.start_link(children, opts)
  end
end
