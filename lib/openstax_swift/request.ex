defmodule OpenStax.Swift.Request do
  require Logger


  @request_headers [
    {"Connection",    "Close"},
    {"Cache-Control", "no-cache, must-revalidate"},
    {"User-Agent",    "OpenStax.Swift/#{OpenStax.Swift.version}"}
  ]
  @timeout 30000
  @request_options [timeout: @timeout, recv_timeout: @timeout, follow_redirect: false]
  @logger_tag "OpenStax.Swift.Request"


  def request(endpoint_id, method, path, expected_status_codes, options \\ []) do
    Logger.info "[#{@logger_tag} #{inspect(endpoint_id)}] Requesting #{String.upcase(to_string(method))} #{path} (expected status codes = #{expected_status_codes}..."
    case OpenStax.Swift.Endpoint.get_config(endpoint_id) do
      nil ->
        Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)}] Unknown endpoint"
        {:error, {:config, :invalid_endpoint}}

      %{auth_token: auth_token, endpoint_url: endpoint_url} ->
        case endpoint_url do
          nil ->
            Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)}] Unable to make request: please set endpoint URL"
            {:error, {:auth, :invalid_endpoint}}

          _ ->

            auth_token_full = cond do
              is_function(auth_token) ->
                apply(auth_token, [])

              true ->
                auth_token
            end


            case auth_token_full do
              nil ->
                Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)}] Unable to make request: please set auth token"
                {:error, {:auth, :unauthorized}}

              _ ->
                headers_full = @request_headers ++ [{"X-Auth-Token", auth_token_full}]
                location_full = endpoint_url <> "/" <> Enum.join(path, "/")

                if options[:headers]  != nil, do: headers_full = headers_full ++ options[:headers]
                if options[:metadata] != nil, do: headers_full = headers_full ++ options[:metadata] # FIXME prefix X-Meta-...
                if options[:query]    != nil, do: location_full = location_full <> "?" <> URI.encode_query(options[:query])

                body_full = case options[:body] do
                  nil ->
                    ""

                  _ ->
                    options[:body]
                end


                Logger.info "[#{@logger_tag} #{inspect(endpoint_id)}] Requesting: method = #{inspect(method)}, location = #{inspect(location_full)}, body = (...) #{byte_size(body_full)} bytes, headers = #{inspect(headers_full)}"
                case HTTPoison.request(method, location_full, body_full, headers_full, @request_options) do
                  {:ok, %HTTPoison.Response{status_code: status_code, body: body, headers: headers}} ->
                    cond do
                      Enum.any?(expected_status_codes, fn(expected_code) -> expected_code == status_code end) ->
                        Logger.info "[#{@logger_tag} #{inspect(endpoint_id)}] Request OK: got status code of #{status_code}"
                        {:ok, status_code, headers, body}

                      true ->
                        case status_code do
                          401 ->
                            Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)}] Request failed: unauthorized"
                            {:error, {:auth, :unauthorized}}

                          _ ->
                            Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)}] Request failed: got unexpected status code of #{status_code}"
                            {:error, {:httpcode, status_code}}
                        end
                    end

                  {:error, reason} ->
                    Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)}] Request failed: HTTP error #{inspect(reason)}"
                    {:error, {:httperror, reason}}
                end
            end
        end
    end
  end
end
