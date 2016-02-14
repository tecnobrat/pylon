defmodule Pylon.Dispatcher do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # `start_server` function is used to spawn the worker process
      worker(__MODULE__, [], function: :start_server)
    ]
    opts = [strategy: :one_for_one, name: Pylon.Dispatcher.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
