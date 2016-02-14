defmodule Pylon.Dispatcher.Router do
  use Plug.Router
  use Plug.Debugger
  use Plug.ErrorHandler
  import Plug.Conn

  plug Pylon.Dispatcher.Plug.JWT
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hello Plug!")
  end

  match _ do
    [status_code, headers, body] = Pylon.Dispatcher.Handle.handle_request(conn)
    IO.puts status_code
    IO.puts body
    IO.puts "Finished Proxy"
    send_resp(conn, status_code, body)
  end

  def start_link do
    Plug.Adapters.Cowboy.http __MODULE__, [], port: 8080
  end

  def stop do
    Plug.Adapters.Cowboy.shutdown __MODULE__
  end

  defp handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    send_resp(conn, conn.status, reason.message)
  end
end
