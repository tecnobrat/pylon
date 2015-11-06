defmodule Pylon do
  use Application

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {:_, [{"/[...]", Pylon.Dispatcher, []}]}
    ])
    {:ok, _} = :cowboy.start_http(:http, 1000, [port: 8080], [env: [dispatch: dispatch]])
    Pylon.DispatcherSupervisor.start_link
  end
end
