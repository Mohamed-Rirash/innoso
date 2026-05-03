defmodule Innoso.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :description, :text
      add :cover_image, :string
      add :live_url, :string
      add :demo_username, :string
      add :demo_password, :string
      add :client_type, :string
      add :tags, :string

      timestamps(type: :utc_datetime)
    end
  end
end
