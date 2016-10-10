defmodule OpenStax.Swift.API.Object do
  @moduledoc """
  This module is responsible for wrapping HTTP requests sent to Swift
  when it comes to object handling.
  """


  @doc """
  Downloads the object content and gets the object metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showObject
  """
  def read(endpoint_id, container, object) do
    OpenStax.Swift.Request.request(endpoint_id, :get, [to_string(container), to_string(object)], [200])
    # TODO parse content
  end


  @doc """
  Creates an object with data content and metadata, or replaces an existing
  object with data content and metadata.

  On success it returns `{:ok, %{etag: "md5 hash of contents"}}`.

  On error it returns `{:error, reason}`.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#createOrReplaceObject
  """
  def create(endpoint_id, container, object, body, content_type \\ "application/octet-stream", content_disposition \\ "attachment", filename \\ nil, metadata \\ nil) do
    headers = [
      {"Content-Type", content_type}
    ]
    headers = cond do
      !is_nil(filename) ->
        headers ++ [{"Content-Disposition", "#{content_disposition}; filename=\"#{String.replace(filename, "\"", "")}\""}]
      true ->
        headers
    end

    case OpenStax.Swift.Request.request(endpoint_id, :put, [to_string(container), to_string(object)], [201], [ body: body, headers: headers, metadata: metadata ]) do
      {:ok, code, headers, body} ->
        {"Etag", etag} = List.keyfind(headers, "Etag", 0)

        {:ok, %{ etag: etag }}

      {:error, reason} ->
        {:error, reason}
    end
  end


  @doc """
  Copies an object to another object in the object store.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#copyObject
  """
  def copy(endpoint_id, source_container, source_object, destination_container, destination_object, copy_manifest \\ false) do
    query = nil
    if copy_manifest, do: query = %{"multipart-manifest" => "copy"}

    OpenStax.Swift.Request.request(endpoint_id, :copy, [to_string(source_container), to_string(source_object)], [201], [
      headers: [{"Destination", "#{destination_container}/#{destination_object}"}],
      query: query
    ])
  end


  @doc """
  Permanently deletes an object from the object store.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#deleteObject
  """
  def delete(endpoint_id, container, object, delete_manifest \\ false) do
    query = nil
    if delete_manifest, do: query = %{"multipart-manifest" => "delete"}

    OpenStax.Swift.Request.request(endpoint_id, :delete, [to_string(container), to_string(object)], [204], [
      query: query
    ])
  end


  @doc """
  Shows object metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showObjectMeta
  """
  def get_meta(endpoint_id, container, object) do
    OpenStax.Swift.Request.request(endpoint_id, :head, [to_string(container), to_string(object)], [200])
    # TODO parse response
  end


  @doc """
  Creates or updates object metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#updateObjectMeta
  """
  def set_meta(endpoint_id, container, object, metadata \\ nil) do
    OpenStax.Swift.Request.request(endpoint_id, :post, [to_string(container), to_string(object)], [202], [
      metadata: metadata
    ])
  end


  @doc """
  Creates or updates Static Large Object manifest.

  You have to pass information about segments that is a list of tuples
  `{container/object, etag, size_bytes}` in order that will compose the object.

  See http://docs.openstack.org/developer/swift/api/large_objects.html#static-large-objects
  """
  def create_slo_manifest(endpoint_id, container, object, segments, metadata \\ nil) do
    OpenStax.Swift.Request.request(endpoint_id, :put, [to_string(container), to_string(object)], [201], [
      body: Poison.encode!(Enum.map(segments, fn({path, etag, size_bytes}) -> %{path: path, etag: etag, size_bytes: size_bytes} end)),
      metadata: metadata,
      query: %{"multipart-manifest" => "put"}
    ])
  end


  @doc """
  Creates or updates Dynamic Large Object manifest.

  See http://docs.openstack.org/developer/swift/api/large_objects.html#dynamic-large-objects
  """
  def create_dlo_manifest(endpoint_id, container, object, segments_container, segments_object_prefix, content_type \\ "application/octet-stream", content_disposition \\ "attachment", filename \\ nil, metadata \\ nil) do
    headers = [
      {"X-Object-Manifest", "#{segments_container}/#{segments_object_prefix}"},
      {"Content-Type", content_type}
    ]
    headers = cond do
      !is_nil(filename) ->
        headers ++ [{"Content-Disposition", "#{content_disposition}; filename=\"#{String.replace(filename, "\"", "")}\""}]
      true ->
        headers
    end

    case OpenStax.Swift.Request.request(endpoint_id, :put, [to_string(container), to_string(object)], [201], [headers: headers, metadata: metadata]) do
      {:ok, code, headers, body} ->
        {"Etag", etag} = List.keyfind(headers, "Etag", 0)

        {:ok, %{ etag: etag }}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
