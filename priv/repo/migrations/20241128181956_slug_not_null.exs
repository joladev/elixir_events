defmodule ElixirEvents.Repo.Migrations.SlugNotNull do
  use Ecto.Migration

  def change do
    alter table(:events) do
      modify :slug, :string, null: true
    end
  end
end
