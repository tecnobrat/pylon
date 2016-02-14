defmodule Pylon.Dispatcher.Handle do
  def handle_request(conn) do
    request_path = conn.request_path
    method = String.to_atom(String.downcase(conn.method))

    upstream_uri = get_upstream_uri(request_path)
    fetch_api(upstream_uri, method)
  end

  def get_upstream_uri(_request_path) do
    uri = "https://www.mumbleboxes.com/sitemap.xml"
    # {:ok, uri} = Pylon.RedixPool.command(~w(GET #{request_path}))
    uri
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
