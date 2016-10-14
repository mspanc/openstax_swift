defmodule OpenStax.Swift do
  use Application

  def version do
    "0.2.0"
  end


  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(OpenStax.Swift.Endpoint, [[name: OpenStax.Swift.Endpoint]])
    ]

    opts = [strategy: :one_for_one, name: OpenStax.Swift]
    Supervisor.start_link(children, opts)
  end
end
