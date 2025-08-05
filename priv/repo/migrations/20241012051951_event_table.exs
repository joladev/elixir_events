defmodule ElixirEvents.Repo.Migrations.EventTable do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :starts_at, :naive_datetime, null: false
      add :title, :string, null: false
      add :url, :string, null: false
      add :description, :string, null: false
      add :logo_url, :string, null: false
      add :location, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
