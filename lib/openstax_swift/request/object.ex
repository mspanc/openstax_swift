defmodule Object do
  @moduledoc """
  This module is responsible for wrapping HTTP requests sent to Swift
  when it comes to object handling.
  """


  @doc """
  Downloads the object content and gets the object metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showObject
  """
  def read(backend_id, container, object) do
    OpenStax.Swift.Request.request(backend_id, :get, [container, object], [200])
    # TODO parse content
  end


  @doc """
  Creates an object with data content and metadata, or replaces an existing
  object with data content and metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showObject
  """
  def create(backend_id, container, object, body, metadata \\ nil) do
    OpenStax.Swift.Request.request(backend_id, :put, [container, object], [201], %{
      body: body, metadata: metadata
    })
  end


  @doc """
  Copies an object to another object in the object store.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#copyObject
  """
  def copy(backend_id, source_container, source_object, destination_container, destination_object, copy_manifest \\ false) do
    query = nil
    if copy_manifest, do: query = %{"multipart-manifest" => "copy"}

    OpenStax.Swift.Request.request(backend_id, :copy, [container, object], [201], %{
      headers: [{"Destination", "#{destination_container}/#{destination_object}"}],
      query: query
    })
  end


  @doc """
  Permanently deletes an object from the object store.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#deleteObject
  """
  def delete(backend_id, container, object, delete_manifest \\ false) do
    query = nil
    if delete_manifest, do: query = %{"multipart-manifest" => "delete"}

    OpenStax.Swift.Request.request(backend_id, :delete, [container, object], [204], %{
      query: query
    })
  end


  @doc """
  Shows object metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showObjectMeta
  """
  def get_meta(backend_id, container, object) do
    OpenStax.Swift.Request.request(backend_id, :head, [container, object], [200])
    # TODO parse response
  end


  @doc """
  Creates or updates object metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#updateObjectMeta
  """
  def set_meta(backend_id, container, object, metadata \\ nil) do
    OpenStax.Swift.Request.request(backend_id, :post, [container, object], [202], %{
      metadata: metadata
    })
  end


  @doc """
  Creates or updates Static Large Object manifest.

  You have to pass information about segments that is a list of tuples
  `{container/object, etag, size_bytes}`.

  See http://docs.openstack.org/developer/swift/api/large_objects.html#static-large-objects
  """
  def create_slo_manifest(backend_id, container, object, segments, metadata \\ nil) do
    OpenStax.Swift.Request.request(backend_id, :put, [container, object], [201], %{
      body: Poison.Encoder.encode(segments),
      metadata: metadata,
      query: %{"multipart-manifest" => "put"}
    })
  end


  @doc """
  Creates or updates Dynamic Large Object manifest.

  See http://docs.openstack.org/developer/swift/api/large_objects.html#dynamic-large-objects
  """
  def create_dlo_manifest(backend_id, container, object, segments_container, segments_object_prefix) do
    OpenStax.Swift.Request.request(backend_id, :put, [container, object], [201], %{
      headers: [{"X-Object-Manifest", "#{segments_container}/#{segments_object_prefix}"}]
    })
  end
end
