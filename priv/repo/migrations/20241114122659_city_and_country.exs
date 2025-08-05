defmodule ElixirEvents.Repo.Migrations.CityAndCountry do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :city, :string
      add :country, :string

      remove :location
    end
  end
end
