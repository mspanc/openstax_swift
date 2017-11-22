defmodule OpenStax.Swift.Request do
  require Logger


  @request_headers [
    {"Cache-Control", "no-cache, must-revalidate"},
    {"User-Agent",    "OpenStax.Swift/#{OpenStax.Swift.version}"}
  ]
  @timeout 30000
  @request_options [timeout: @timeout, recv_timeout: @timeout, follow_redirect: false]
  @logger_tag "OpenStax.Swift.Request"


  def request(endpoint_id, method, path, expected_status_codes, options \\ []) when is_list(path) do
    Logger.debug "[#{@logger_tag} #{inspect(endpoint_id)} #{inspect(self())}] Requesting #{String.upcase(to_string(method))} #{inspect(path)} with options #{inspect(options)} (expected status codes = #{inspect(expected_status_codes)})..."
    case OpenStax.Swift.Endpoint.get_config(endpoint_id) do
      nil ->
        Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)} #{inspect(self())}] Unknown endpoint"
        {:error, {:config, :invalid_endpoint}}

      %{auth_token: auth_token, endpoint_url: endpoint_url} ->
        case endpoint_url do
          nil ->
            Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)} #{inspect(self())}] Unable to make request: please set endpoint URL"
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
                Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)} #{inspect(self())}] Unable to make request: please set auth token"
                {:error, {:auth, :unauthorized}}

              _ ->
                headers_full = @request_headers ++ [{"X-Auth-Token", auth_token_full}]
                location_full = endpoint_url <> "/" <> Enum.join(path, "/")

                headers_full  = if options[:headers]  != nil, do: headers_full ++ options[:headers], else: headers_full
                headers_full  = if options[:metadata] != nil, do: headers_full ++ options[:metadata], else: headers_full # FIXME prefix X-Meta-...
                location_full = if options[:query]    != nil, do: location_full <> "?" <> URI.encode_query(options[:query]), else: location_full

                body_full = case options[:body] do
                  nil           ->  ""
                  {:file, path} -> {:file, path}
                  _             -> options[:body]
                end

                case HTTPoison.request(method, location_full, body_full, headers_full, @request_options) do
                  {:ok, %HTTPoison.Response{status_code: status_code, body: body, headers: headers}} ->
                    cond do
                      Enum.any?(expected_status_codes, fn(expected_code) -> expected_code == status_code end) ->
                        Logger.debug "[#{@logger_tag} #{inspect(endpoint_id)} #{inspect(self())}] Request to #{String.upcase(to_string(method))} #{inspect(path)} OK: got status code of #{status_code}"
                        {:ok, status_code, headers, body}

                      true ->
                        case status_code do
                          401 ->
                            Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)} #{inspect(self())}] Request to #{String.upcase(to_string(method))} #{inspect(path)} failed: unauthorized"
                            {:error, {:auth, :unauthorized}}

                          _ ->
                            Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)} #{inspect(self())}] Request to #{String.upcase(to_string(method))} #{inspect(path)} failed: got unexpected status code of #{status_code}"
                            {:error, {:httpcode, status_code}}
                        end
                    end

                  {:error, reason} ->
                    Logger.warn "[#{@logger_tag} #{inspect(endpoint_id)} #{inspect(self())}] Request to #{String.upcase(to_string(method))} #{inspect(path)} failed: HTTP error #{inspect(reason)}"
                    {:error, {:httperror, reason}}
                end
            end
        end
    end
  end
end
