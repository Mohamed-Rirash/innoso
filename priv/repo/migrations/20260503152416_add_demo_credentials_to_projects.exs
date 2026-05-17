defmodule Innoso.Repo.Migrations.AddDemoCredentialsToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :demo_credentials, :text, default: "[]"
      remove :demo_username, :string
      remove :demo_password, :string
    end
  end
end
