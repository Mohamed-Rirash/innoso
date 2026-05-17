defmodule Innoso.Repo.Migrations.AddBioSkillsToMembers do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :bio, :text
      add :skills, :string
    end
  end
end
