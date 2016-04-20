defmodule OpenStax.Swift.Endpoint do
  @moduledoc """
  This module is responsible for storing configuration of Swift endpoints.
  """

  @doc """
  Starts a new agent for storing configuration.
  """
  def start_link(opts \\ []) do
    Agent.start_link(fn -> %{} end, opts)
  end


  @doc """
  Registers new endpoint.
  """
  def register(endpoint_id, auth_token \\ nil, endpoint_url \\ nil, signing_key \\ nil) do
    Agent.update(OpenStax.Swift.Endpoint, fn(state) ->
      Map.put(state, endpoint_id, %{auth_token: auth_token, endpoint_url: endpoint_url, signing_key: signing_key})
    end)
  end


  @doc """
  Returns current access token for a endpoint.
  """
  def get_config(endpoint_id) do
    Agent.get(OpenStax.Swift.Endpoint, fn(state) ->
      Map.get(state, endpoint_id)
    end)
  end


  @doc """
  Sets current configuration for a endpoint.
  """
  def set_config(endpoint_id, auth_token, endpoint_url, signing_key \\ nil) do
    Agent.update(OpenStax.Swift.Endpoint, fn(state) ->
      Map.put(state, endpoint_id, %{auth_token: auth_token, endpoint_url: endpoint_url, signing_key: signing_key})
    end)
  end
end
