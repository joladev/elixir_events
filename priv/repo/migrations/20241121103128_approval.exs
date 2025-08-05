defmodule ElixirEvents.Repo.Migrations.Approval do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :approved, :boolean, default: false
    end
  end
end
