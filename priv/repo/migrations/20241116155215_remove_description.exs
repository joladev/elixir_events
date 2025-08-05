defmodule ElixirEvents.Repo.Migrations.RemoveDescription do
  use Ecto.Migration

  def change do
    alter table(:events) do
      remove :description
    end
  end
end
