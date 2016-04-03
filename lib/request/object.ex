defmodule OpenStax.Swift.Request.Object do
  @moduledoc """
  This module is responsible for wrapping HTTP requests sent to Swift
  when it comes to object handling.
  """


  @doc """
  Downloads the object content and gets the object metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showObject
  """
  def read(backend_id, container, object) do
    OpenStax.Swift.Request.request(backend_id, [container, object], :get, nil, nil, [200])
    # TODO parse content
  end


  @doc """
  Creates an object with data content and metadata, or replaces an existing
  object with data content and metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showObject
  """
  def create(backend_id, container, object, body, metadata \\ []) do
    OpenStax.Swift.Request.request(backend_id, [container, object], :put, body, metadata, [201])
  end


  @doc """
  Copies an object to another object in the object store.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#copyObject
  """
  def copy(backend_id, source_container, source_object, destination_container, destination_object) do
    OpenStax.Swift.Request.request(backend_id, [container, object], :copy, body, metadata, [201], [{"Destination", "#{destination_container}/#{destination_object}"}])
  end


  @doc """
  Permanently deletes an object from the object store.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#deleteObject
  """
  def delete(backend_id, container, object) do
    # TODO add ?multipart-manifest=delete support
    OpenStax.Swift.Request.request(backend_id, [container, object], :delete, nil, nil, [204])
  end


  @doc """
  Shows object metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showObjectMeta
  """
  def get_meta(backend_id, container, object) do
    OpenStax.Swift.Request.request(backend_id, [container, object], :head, nil, metadata, [200])
    # TODO parse response
  end


  @doc """
  Creates or updates object metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#updateObjectMeta
  """
  def set_meta(backend_id, container, object, metadata \\ []) do
    OpenStax.Swift.Request.request(backend_id, [container, object], :post, nil, metadata, [202])
  end



end
