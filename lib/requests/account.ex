defmodule OpenStax.Swift.Account do
  @moduledoc """
    This module is responsible for wrapping HTTP requests sent to Swift
    when it comes to account handling.
  """

  @request_headers [
    {"Connection",    "Close"},
    {"Cache-Control", "no-cache, must-revalidate"},
    {"User-Agent",    "OpenStax.Swift"}
  ]
  @timeout 5000
  @request_options [timeout: @timeout, recv_timeout: @timeout, follow_redirect: false]


  def create(endpoint_url, auth_token, metadata) do
    case HTTPoison.request(:post, build_location(endpoint_url), "", build_headers(auth_token, metadata), @request_options) do
      {:ok, %HTTPoison.Response{status_code: status_code, headers: headers}} ->
        case status_code do
          204 ->
            :ok

          _ ->
            {:error, {:httpcode, status_code}}
        end

      {:error, reason} ->
        {:error, {:httperror, reason}}
    end
  end


  defp build_location(endpoint_url) do
    endpoint_url
  end


  defp build_headers(auth_token, metadata) do
    @request_headers ++ [{"X-Auth-Token", auth_token}] ++ metadata
  end
end
