defmodule Account do
  @moduledoc """
  This module is responsible for wrapping HTTP requests sent to Swift
  when it comes to account handling.
  """

  import OpenStax.Swift.Request


  @doc """
  Creates, updates, or deletes account metadata.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#updateAccountMeta
  """
  def create(backend_id, metadata \\ nil) do
    request(backend_id, :post, [], [200], %{
      metadata: metadata
    })
  end


  @doc """
  Shows details for an account and lists containers, sorted by name, in the account.

  See http://developer.openstack.org/api-ref-objectstorage-v1.html#showAccountDetails
  """
  def read(backend_id) do
    request(backend_id, :get, [], [204])
    # TODO parse response
  end
end
