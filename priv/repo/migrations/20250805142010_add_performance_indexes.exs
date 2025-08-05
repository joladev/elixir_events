defmodule ElixirEvents.Repo.Migrations.AddPerformanceIndexes do
  use Ecto.Migration

  def change do
    create index(:events, [:slug])
    create index(:events, [:starts_at])
    create index(:events, [:country, :city])
  end
end
