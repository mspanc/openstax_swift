defmodule OpenStax.Swift.Request do
  @request_headers [
    {"Connection",    "Close"},
    {"Cache-Control", "no-cache, must-revalidate"},
    {"User-Agent",    "OpenStax.Swift/#{OpenStax.Swift.version}"}
  ]
  @timeout 30000
  @request_options [timeout: @timeout, recv_timeout: @timeout, follow_redirect: false]


  def request(backend_id, method, path, expected_status_codes, options \\ []) do
    case OpenStax.Swift.AuthAgent.get_config(backend_id) do
      nil ->
        {:error, {:config, :invalid_backend}}

      %{auth_token: auth_token, endpoint_url: endpoint_url} ->
        case endpoint_url do
          nil ->
            {:error, {:auth, :invalid_endpoint}}

          _ ->
            case auth_token do
              nil ->
                {:error, {:auth, :unauthorized}}

              _ ->
                headers_full = @request_headers ++ [{"X-Auth-Token", auth_token}]
                location_full = endpoint_url <> "/" <> Enum.join(path, "/")

                if options[:headers]  != nil, do: headers_full = headers_full ++ options[:headers]
                if options[:metadata] != nil, do: headers_full = headers_full ++ options[:metadata] # FIXME prefix X-Meta-...
                if options[:query]    != nil, do: location_full = location_full <> "?" <> URI.encode_query(options[:query])

                case HTTPoison.request(method, location_full, options[:body], headers_full, @request_options) do
                  {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
                    case status_code do
                      401 ->
                        {:error, {:auth, :unauthorized}}

                      expected_status_code ->
                        {:ok, status_code, body} # TODO parse body

                      _ ->
                        {:error, {:httpcode, status_code}}
                    end

                  {:error, reason} ->
                    {:error, {:httperror, reason}}
                end
            end
        end
    end
  end
end
