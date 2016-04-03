defmodule OpenStax.Swift.Request.Account do
  @moduledoc """
  This module is responsible for wrapping HTTP requests sent to Swift
  when it comes to account handling.
  """


  @doc """
  Creates, updates, or deletes account metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#updateAccountMeta
  """
  def create(backend_id, metadata) do
    OpenStax.Swift.Request.request(backend_id, [], :post, nil, metadata, [200])
  end


  @doc """
  Shows details for an account and lists containers, sorted by name, in the account.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showAccountDetails
  """
  def read(backend_id) do
    OpenStax.Swift.Request.request(backend_id, [], :get, nil, [], [204])
  end
end
