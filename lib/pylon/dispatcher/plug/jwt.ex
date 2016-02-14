defmodule Pylon.Dispatcher.Plug.JWT do
  import Plug.Conn
  use Behaviour

  defmodule MissingJWTTokenError do
    @moduledoc "Error raised when JWT token is missing."

    message = "Missing JWT token."

    defexception message: message, plug_status: 401
  end

  defmodule InvalidJWTTokenError do
    @moduledoc "Error raised when JWT token is invalid."

    message = "Invalid JWT token."

    defexception message: message, plug_status: 403
  end

  @behaviour Plug
  @jwt_secret "secret"

  def init(opts), do: Keyword.get(opts, :with, :exception)

  def call(conn, mode) do
    register_before_send(conn, &verify_request!(&1))
  end

  defp get_jwt_token_from_header(conn) do
    auth_header = get_req_header(conn, "authorization") |> List.first
    parse_authorization_header(auth_header)
  end

  defp parse_authorization_header("Bearer " <> token) when token != "",  do: token

  defp parse_authorization_header(_) do
    :missing
  end

  defp verify_request!(conn) do
    case get_jwt_token_from_header(conn) do
      :missing ->
        raise MissingJWTTokenError
      token ->
        verify_secret!(token)
    end
    conn
  end

  defp verify_secret!(token) do
    case :ejwt.parse_jwt(token, @jwt_secret) do
      :invalid ->
        raise InvalidJWTTokenError
      _ ->
        token
    end
  end
end
