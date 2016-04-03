defmodule OpenStax.Swift.AuthAgent do
  @moduledoc """
    This module is responsible for storing configuration of Swift backends.
  """

  @process_id OpenStax.Swift.AuthAgent


  @doc """
  Starts a new agent for storing configuration.
  """
  def start_link() do
    Agent.start_link(fn -> %{} end, [name: @process_id])
  end


  @doc """
  Registers new backend.
  """
  def register(backend_id) do
    Agent.get(@process_id, fn
      Agent.update(@process_id, fn(state) ->
        %{state | backend_id => %{auth_token: nil, endpoint_url: nil}}
       end)
    end)
  end


  @doc """
  Returns current access token for a backend.
  """
  def get_config(backend_id) do
    Agent.get(@process_id, fn(state) ->
      state[backend_id]
    end)
  end


  @doc """
  Sets current configuration for a backend.
  """
  def set_config(backend_id, auth_token, endpoint_url) do
    Agent.update(@process_id, fn(state) ->
      %{state | backend_id => %{auth_token: auth_token, endpoint_url: endpoint_url}}
    end)
  end
end
