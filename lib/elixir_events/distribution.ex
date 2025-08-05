defmodule ElixirEvents.Distribution do
  @moduledoc """
  GenServer for managing distributed node connections and consistent hashing.

  Monitors cluster nodes and maintains a consistent hash ring for distributing
  work across the cluster using ExHashRing.
  """
  use GenServer

  alias ElixirEvents.DistributionRing

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    :net_kernel.monitor_nodes(true)

    for node <- [Node.self() | Node.list()] do
      ExHashRing.Ring.add_node(DistributionRing, node)
    end

    {:ok, []}
  end

  @impl GenServer
  def handle_info({:nodeup, node}, state) do
    Logger.info("Node #{node} connected")
    ExHashRing.Ring.add_node(DistributionRing, node)
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    Logger.info("Node #{node} disconnected")
    ExHashRing.Ring.remove_node(DistributionRing, node)
    {:noreply, state}
  end
end
