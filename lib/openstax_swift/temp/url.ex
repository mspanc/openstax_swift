defmodule OpenStax.Swift.Temp.URL do
  @moduledoc """
    This module is responsible for generating Temp URLs for objects.
  """


  def generate(endpoint_url, container, object_id, key, expires_in) do
    %URI{path: endpoint_path} = URI.parse(endpoint_url)
    path = endpoint_path <> "/" <> container <> "/" <> object_id

    {mega, sec, _} = :os.timestamp
    unix_timestamp_now = mega * 1000000 + sec

    temp_url_expires = unix_timestamp_now + expires_in
    temp_url_sig = Base.encode16(:crypto.hmac(:sha, key, "GET\n" <> to_string(temp_url_expires) <> "\n" <> path), case: :lower)

    endpoint_url <> "/" <> container <> "/" <> object_id <> "?" <>
      URI.encode_query(%{
        temp_url_expires: temp_url_expires,
        temp_url_sig: temp_url_sig
      })
  end


end
