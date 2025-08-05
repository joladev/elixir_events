defmodule ElixirEvents.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    :logger.add_handler(:my_sentry_handler, Sentry.LoggerHandler, %{
      config: %{metadata: [:file, :line]}
    })

    children = [
      {ExHashRing.Ring, name: ElixirEvents.DistributionRing},
      {ElixirEvents.Distribution, []},
      ElixirEventsWeb.Telemetry,
      ElixirEvents.Repo,
      {DNSCluster, query: Application.get_env(:elixir_events, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirEvents.PubSub},
      {Finch, name: ElixirEvents.Finch},
      {ElixirEvents.RateLimit, [clean_period: :timer.minutes(1)]},
      ElixirEventsWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: ElixirEvents.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl Application
  def config_change(changed, _new, removed) do
    ElixirEventsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
