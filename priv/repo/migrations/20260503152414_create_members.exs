defmodule Innoso.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :name, :string
      add :role, :string
      add :photo, :string
      add :sort_order, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
