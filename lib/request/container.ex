defmodule OpenStax.Swift.Request.Container do
  @moduledoc """
  This module is responsible for wrapping HTTP requests sent to Swift
  when it comes to container handling.
  """


  @doc """
  Shows details for a container and lists objects, sorted by name, in the container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showContainerDetails
  """
  def read(backend_id, container) do
    OpenStax.Swift.Request.request(backend_id, [container], :get, nil, nil, [200, 204])
  end


  @doc """
  Creates a container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#createContainer
  """
  def create(backend_id, container, metadata \\ []) do
    OpenStax.Swift.Request.request(backend_id, [container], :put, nil, metadata, [201])
  end


  @doc """
  Deletes an empty container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#deleteContainer
  """
  def delete(backend_id, container) do
    OpenStax.Swift.Request.request(backend_id, [container], :delete, nil, nil, [204])
  end


  @doc """
  Creates, updates, or deletes custom metadata for a container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#updateContainerMeta
  """
  def set_meta(backend_id, container, metadata \\ []) do
    OpenStax.Swift.Request.request(backend_id, [container], :post, nil, metadata, [204])
  end


  @doc """
  Shows container metadata, including the number of objects and the total bytes
  of all objects stored in the container.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showContainerMeta
  """
  def get_meta(backend_id, container) do
    OpenStax.Swift.Request.request(backend_id, [container], :head, nil, nil, [204])
    # TODO parse response
  end
end
