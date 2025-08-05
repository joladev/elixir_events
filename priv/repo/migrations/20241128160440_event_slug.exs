defmodule ElixirEvents.Repo.Migrations.EventSlug do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :slug, :string, null: true
    end
  end
end
