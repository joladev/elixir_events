defmodule ElixirEvents.Repo.Migrations.OnlineOnlyEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :online_only, :boolean, default: false, null: false
    end
  end
end
