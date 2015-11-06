defmodule Pylon.Dispatcher do
  def init(_transport, req, []) do
    {:ok, req, nil}
  end

  def handle(req, state) do
    jwt_data = parse_auth_header(req)
    if jwt_data == :invalid do
      {:ok, req} = :cowboy_req.reply(403, [], '{ error: "Invalid JWT" }', req)
    else
      {request_path, _} = :cowboy_req.path(req)
      request_path_parts = String.split(request_path, "/", parts: 2, trim: true)
      uri = get_upstream_uri(List.first(request_path_parts))

      [status_code, headers, body] = fetch_api(uri)
      {:ok, req} = :cowboy_req.reply(status_code, headers, body, req)
    end
    {:ok, req, state}
  end

  def get_upstream_uri(request_path) do
    {:ok, redis_client} = Exredis.start_link
    redis_client |> Exredis.query ["SET", "tecnobrat", "https://www.tecnobrat.com/sitemap.xml"]
    redis_client |> Exredis.query ["SET", "mumbleboxes", "https://www.mumbleboxes.com/sitemap.xml"]
    uri = redis_client |> Exredis.query ["GET", request_path]
    redis_client |> Exredis.stop
    uri
  end

  def parse_auth_header(req) do
    jwt_secret = "secret"

    claims = {[ {:user_id, 1} ]}
    expiration_seconds = 86400
    token = :ejwt.jwt("HS256", claims, expiration_seconds, jwt_secret)

    {:ok, {_, jwt_value}, _} = auth_header = :cowboy_req.parse_header("authorization", req)
    :ejwt.parse_jwt(jwt_value, jwt_secret)
  end

  def fetch_api(:undefined) do
    [404, [], "Not found :("]
  end

  def fetch_api(uri) do
    IO.inspect("Fetching: " <> uri)
    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        [200, [], body]
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        [404, [], "Not found :("]
      {:error, %HTTPoison.Error{reason: reason}} ->
        [500, [], reason]
    end
  end

  def terminate(_reason, _req, _state), do: :ok
end
