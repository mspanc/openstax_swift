defmodule OpenStax.Swift.Object do
  @moduledoc """
    This module is responsible for wrapping HTTP requests sent to Swift
    when it comes to object handling.
  """

  @request_headers [
    {"Connection",    "Close"},
    {"Cache-Control", "no-cache, must-revalidate"},
    {"User-Agent",    "OpenStax.Swift"}
  ]
  @timeout 5000
  @request_options [timeout: @timeout, recv_timeout: @timeout, follow_redirect: false]


  def create(endpoint_url, auth_token, container, object_id, object_contents) do
    case HTTPoison.request(:put, build_location(endpoint_url, container, object_id), object_contents, build_headers(auth_token), @request_options) do
      {:ok, %HTTPoison.Response{status_code: status_code, headers: headers}} ->
        case status_code do
          201 ->
            :ok

          _ ->
            {:error, {:httpcode, status_code}}
        end

      {:error, reason} ->
        {:error, {:httperror, reason}}
    end
  end


  def create_dlo_segment(endpoint_url, auth_token, container, object_id, chunk_index, object_contents) do
    case HTTPoison.request(:put, build_location_dlo(endpoint_url, container, object_id, chunk_index), object_contents, build_headers(auth_token), @request_options) do
      {:ok, %HTTPoison.Response{status_code: status_code, headers: headers}} ->
        case status_code do
          201 ->
            :ok

          _ ->
            {:error, {:httpcode, status_code}}
        end

      {:error, reason} ->
        {:error, {:httperror, reason}}
    end
  end


  def create_dlo_manifest(endpoint_url, auth_token, container, object_id, segment_prefix) do
    case HTTPoison.request(:put, build_location(endpoint_url, container, object_id), "", build_headers_dlo_manifest(auth_token, container, object_id, segment_prefix), @request_options) do
      {:ok, %HTTPoison.Response{status_code: status_code, headers: headers}} ->
        case status_code do
          201 ->
            :ok

          _ ->
            {:error, {:httpcode, status_code}}
        end

      {:error, reason} ->
        {:error, {:httperror, reason}}
    end
  end


  def get(endpoint_url, auth_token, container, object_id) do
    case HTTPoison.request(:get, build_location(endpoint_url, container, object_id), "", build_headers(auth_token), @request_options) do
      {:ok, %HTTPoison.Response{status_code: status_code, headers: headers, body: body}} ->
        case status_code do
          200 ->
            {:ok, body}

          _ ->
            {:error, {:httpcode, status_code}}
        end

      {:error, reason} ->
        {:error, {:httperror, reason}}
    end
  end


  defp build_location(endpoint_url, container, object_id) do
    endpoint_url <> "/" <> container <> "/" <> object_id
  end


  defp build_location_dlo(endpoint_url, container, object_id, chunk_index) do
    endpoint_url <> "/" <> container <> "/" <> object_id <> "_" <> zero_pad(chunk_index, 24)
  end


  defp build_headers(auth_token) do
    @request_headers ++ [{"X-Auth-Token", auth_token}]
  end


  defp build_headers_dlo_manifest(auth_token, container, object_id, segment_prefix) do
    @request_headers ++ [{"X-Auth-Token", auth_token}, {"X-Object-Manifest", container <> "/" <> segment_prefix <> "_"}]
  end


  def zero_pad(val, count) do
    num = Integer.to_string(val)
    :binary.copy("0", count - byte_size(num)) <> num
  end
end
