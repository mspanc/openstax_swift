defmodule OpenStax.Swift.Middleware.TempURL do
  @moduledoc """
  This module is responsible for generating temporary URLs for objects.

  See http://docs.openstack.org/developer/swift/api/temporary_url_middleware.html
  """


  @doc """
  Generates temporary public URL for specified object.

  You must set keys as a metadata of container prior to generating such URL.
  """
  def generate(endpoint_id, container, object, expires_in) do
    case OpenStax.Swift.Endpoint.get_config(endpoint_id) do
      nil ->
        {:error, {:config, :invalid_endpoint}}

      %{signing_key: signing_key, endpoint_url: endpoint_url} ->
        case endpoint_url do
          nil ->
            {:error, {:auth, :invalid_endpoint}}

          _ ->
            %URI{path: endpoint_path} = URI.parse(endpoint_url)
            path = endpoint_path <> "/" <> to_string(container) <> "/" <> to_string(object)

            {mega, sec, _} = :os.timestamp
            unix_timestamp_now = mega * 1000000 + sec

            temp_url_expires = unix_timestamp_now + expires_in
            temp_url_sig = Base.encode16(:crypto.hmac(:sha, signing_key, "GET\n" <> to_string(temp_url_expires) <> "\n" <> path), case: :lower)

            endpoint_url <> "/" <> to_string(container) <> "/" <> to_string(object) <> "?" <>
              URI.encode_query(%{
                temp_url_expires: temp_url_expires,
                temp_url_sig: temp_url_sig
              })

        end
    end
  end
end
