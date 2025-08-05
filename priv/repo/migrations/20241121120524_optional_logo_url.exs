defmodule ElixirEvents.Repo.Migrations.OptionalLogoUrl do
  use Ecto.Migration

  def change do
    alter table(:events) do
      modify :logo_url, :string, null: true
    end
  end
end
