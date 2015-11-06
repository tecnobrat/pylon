defmodule Pylon.Dispatcher do
  def init(_transport, req, []) do
    {:ok, req, nil}
  end

  def handle(req, state) do
    case verify_jwt(req) do
      :invalid ->
        {:ok, _} = :cowboy_req.reply(403, [], '{ error: "Invalid JWT" }', req)
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
    {:ok, redis_client} = Exredis.start_link
    redis_client |> Exredis.query ["SET", "tecnobrat", "https://www.tecnobrat.com/sitemap.xml"]
    redis_client |> Exredis.query ["SET", "mumbleboxes", "https://www.mumbleboxes.com/sitemap.xml"]
    uri = redis_client |> Exredis.query ["GET", request_path]
    redis_client |> Exredis.stop
    uri
  end

  def verify_jwt(req) do
    jwt_secret = "secret"
    {:ok, {_, jwt_value}, _} = :cowboy_req.parse_header("authorization", req)
    :ejwt.parse_jwt(jwt_value, jwt_secret)
  end

  def fetch_api(:undefined) do
    [404, [], "Not found :("]
  end

  def fetch_api(uri, method, body \\ :undefined, headers \\ [], options \\ []) do
    IO.inspect("Fetching: " <> uri)
    case execute_api(uri, method, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        [status_code, [], body]
      {:error, %HTTPoison.Error{reason: reason}} ->
        [500, [], reason]
    end
  rescue
    _ -> [500, [], ""]
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
