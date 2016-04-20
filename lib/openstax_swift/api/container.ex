defmodule OpenStax.Swift.API.Container do
  @moduledoc """
  This module is responsible for wrapping HTTP OpenStax.Swift.Request.requests sent to Swift
  when it comes to container handling.
  """


  @doc """
  Shows details for a container and lists objects, sorted by name, in the container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showContainerDetails
  """
  def read(endpoint_id, container) do
    OpenStax.Swift.Request.request(endpoint_id, :get, [to_string(container)], [200, 204])
    # TODO parse response
  end


  @doc """
  Creates a container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#createContainer
  """
  def create(endpoint_id, container, metadata \\ nil) do
    OpenStax.Swift.Request.request(endpoint_id, :put, [to_string(container)], [201], [
      metadata: metadata
    ])
  end


  @doc """
  Deletes an empty container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#deleteContainer
  """
  def delete(endpoint_id, container) do
    OpenStax.Swift.Request.request(endpoint_id, :delete, [to_string(container)], [204])
  end


  @doc """
  Creates, updates, or deletes custom metadata for a container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#updateContainerMeta
  """
  def set_meta(endpoint_id, container, metadata \\ nil) do
    OpenStax.Swift.Request.request(endpoint_id, :post, [to_string(container)], [204], [
      metadata: metadata
    ])
  end


  @doc """
  Shows container metadata, including the number of objects and the total bytes
  of all objects stored in the container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showContainerMeta
  """
  def get_meta(endpoint_id, container) do
    OpenStax.Swift.Request.request(endpoint_id, :head, [to_string(container)], [204])
    # TODO parse response
  end
end
