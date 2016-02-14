defmodule Pylon do
  use Application

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {:_, [{"/[...]", Pylon.Dispatcher, []}]}
    ])
    http_port = Application.fetch_env!(:pylon, :http_port)
    {:ok, _} = :cowboy.start_http(:http, 1000, [port: http_port], [env: [dispatch: dispatch]])
    Pylon.DispatcherSupervisor.start_link
  end
end
