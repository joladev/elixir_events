Mimic.copy(ElixirEvents.RateLimit)
Mimic.copy(Req)
Mimic.copy(ElixirEvents.Notification)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ElixirEvents.Repo, :manual)
