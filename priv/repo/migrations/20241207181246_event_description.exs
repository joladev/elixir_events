defmodule ElixirEvents.Repo.Migrations.EventDescription do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :description, :text, null: true
    end
  end
end
