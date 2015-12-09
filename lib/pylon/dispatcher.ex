defmodule Pylon.Dispatcher do
  def init(_transport, req, []) do
    {:ok, req, nil}
  end

  def handle(req, state) do
    case verify_jwt(req) do
      :invalid ->
        {:ok, _} = :cowboy_req.reply(403, [], '{ error: "Invalid JWT" }', req)
      :missing ->
        {:ok, _} = :cowboy_req.reply(401, [], '{ error: "Authorization Required" }', req)
      _ ->
        handle_request(req)
    end
    {:ok, req, state}
  end

  def handle_request(req) do
    {request_path, _} = :cowboy_req.path(req)
    request_path_parts = String.split(request_path, "/", parts: 2, trim: true)
    uri = get_upstream_uri(List.first(request_path_parts))
    {method, _} = :cowboy_req.method(req)
    method = String.to_atom(String.downcase(method))

    [status_code, headers, body] = fetch_api(uri, method)
    {:ok, _} = :cowboy_req.reply(status_code, headers, body, req)
  end

  def get_upstream_uri(request_path) do
    Pylon.RedixPool.command(~w(SET tecnobrat https://www.google.ca/))
    Pylon.RedixPool.command(~w(SET mumbleboxes https://www.mumbleboxes.com/sitemap.xml))
    {:ok, uri} = Pylon.RedixPool.command(~w(GET #{request_path}))
    uri
  end

  def verify_jwt(_) do
    :yup
  end

  def verify_jwt(req) do
    jwt_secret = "secret"
    case :cowboy_req.parse_header("authorization", req) do
      {:ok, {_, jwt_value}, _} ->
        :ejwt.parse_jwt(jwt_value, jwt_secret)
      _ ->
        :missing
    end
  end

  def fetch_api(:undefined) do
    [404, [], "Not found :("]
  end

  def fetch_api(uri, method, body \\ :undefined, headers \\ [], options \\ []) do
    case execute_api(uri, method, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        [status_code, [], body]
      {:error, %HTTPoison.Error{reason: reason}} ->
        [502, [], reason]
    end
  rescue
    _ -> [504, [], '{ error: "Gateway Timeout" }']
  end

  def execute_api(uri, method, body, headers, options) when method == :post or method == :patch or method == :put do
    IO.inspect "OMG ITS A POST OR SOMETHING"
    IO.inspect [uri, method, body, headers, options]
    apply(HTTPoison, method, [uri, body, headers, options])
  end

  def execute_api(uri, method, _body, headers, options) do
    apply(HTTPoison, method, [uri, headers, options])
  end

  def terminate(_reason, _req, _state), do: :ok
end
