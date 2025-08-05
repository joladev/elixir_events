defmodule ElixirEvents.Repo.Migrations.Timezone do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :timezone, :string
    end
  end
end
