defmodule ElixirEvents.Repo.Migrations.EventEndsAt do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :ends_at, :naive_datetime, null: true
    end
  end
end
