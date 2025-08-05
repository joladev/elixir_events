defmodule ElixirEvents.Repo.Migrations.EventType do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :type, :string, null: false, default: "conference"
    end
  end
end
