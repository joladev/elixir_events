defmodule ElixirEvents.RateLimit do
  @moduledoc """
  Rate limiting functionality for ElixirEvents using Hammer.

  Provides functions to check rate limits for various actions,
  particularly for the event proposal form.
  """

  use Hammer, backend: :ets

  @doc """
  Checks if an IP address is rate limited for event proposals.

  ## Parameters
    - ip_address: The IP address to check (as a string)
    
  ## Returns
    - {:allow, count} if the request is allowed
    - {:deny, limit} if the request is rate limited
  """
  def check_event_proposal(ip_address) do
    # 6 events per hour per IP
    # 1 hour in milliseconds
    scale_ms = 60_000 * 60
    limit = 6

    bucket = "event_proposal:#{ip_address}"

    hit(bucket, scale_ms, limit)
  end

  @doc """
  Gets IP address from LiveView socket during mount.

  ## Parameters
    - socket: The LiveView socket with peer_data
    
  ## Returns
    - String representation of the IP address or "unknown" if not available
  """
  def get_ip_address(socket) do
    case Phoenix.LiveView.get_connect_info(socket, :peer_data) do
      %{address: address} when is_tuple(address) ->
        address
        |> Tuple.to_list()
        |> Enum.join(".")

      _ ->
        "unknown"
    end
  end
end
