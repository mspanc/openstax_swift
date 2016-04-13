defmodule OpenStax.Swift.API.Container do
  @moduledoc """
  This module is responsible for wrapping HTTP OpenStax.Swift.Request.requests sent to Swift
  when it comes to container handling.
  """


  @doc """
  Shows details for a container and lists objects, sorted by name, in the container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showContainerDetails
  """
  def read(backend_id, container) do
    OpenStax.Swift.Request.request(backend_id, :get, [container], [200, 204])
    # TODO parse response
  end


  @doc """
  Creates a container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#createContainer
  """
  def create(backend_id, container, metadata \\ nil) do
    OpenStax.Swift.Request.request(backend_id, :put, [container], [201], [
      metadata: metadata
    ]
  end


  @doc """
  Deletes an empty container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#deleteContainer
  """
  def delete(backend_id, container) do
    OpenStax.Swift.Request.request(backend_id, :delete, [container], [204])
  end


  @doc """
  Creates, updates, or deletes custom metadata for a container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#updateContainerMeta
  """
  def set_meta(backend_id, container, metadata \\ nil) do
    OpenStax.Swift.Request.request(backend_id, :post, [container], [204], [
      metadata: metadata
    ]
  end


  @doc """
  Shows container metadata, including the number of objects and the total bytes
  of all objects stored in the container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showContainerMeta
  """
  def get_meta(backend_id, container) do
    OpenStax.Swift.Request.request(backend_id, :head, [container], [204])
    # TODO parse response
  end
end
