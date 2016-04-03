defmodule OpenStax.Swift.Request do
  @request_headers [
    {"Connection",    "Close"},
    {"Cache-Control", "no-cache, must-revalidate"},
    {"User-Agent",    "OpenStax.Swift"}
  ]
  @timeout 5000
  @request_options [timeout: @timeout, recv_timeout: @timeout, follow_redirect: false]


  def request(backend_id, path, method, body, metadata, expected_status_codes, extra_headers \\ []) do
    # TODO add metadata and auth headers
    case HTTPoison.request(:post, build_location(endpoint_url, container), "", @request_headers, @request_options) do
      {:ok, %HTTPoison.Response{status_code: status_code, headers: headers, body: body}} ->
        case status_code do
          expected_status_code ->
            {:ok, status_code, body} # TODO parse body

          _ ->
            {:error, {:httpcode, status_code}}
        end

      {:error, reason} ->
        {:error, {:httperror, reason}}
  end
end
