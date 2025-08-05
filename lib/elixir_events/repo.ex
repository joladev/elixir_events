defmodule ElixirEvents.Repo do
  use Ecto.Repo,
    otp_app: :elixir_events,
    adapter: Ecto.Adapters.Postgres
end
