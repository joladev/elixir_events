defmodule ElixirEvents.Repo.Migrations.SuggestionTable do
  use Ecto.Migration

  def change do
    create table(:suggestions) do
      add :description, :string, null: false
      add :event_id, references(:events, on_delete: :delete_all), null: false
      add :checked, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
