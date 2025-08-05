defmodule ElixirEvents.Repo.Migrations.EndsAtNotNull do
  use Ecto.Migration

  def change do
    alter table(:events) do
      modify :ends_at, :naive_datetime, null: false
    end
  end
end
