defmodule Innoso.Repo.Migrations.CreateSchedulingConfigs do
  use Ecto.Migration

  def change do
    create table(:scheduling_configs) do
      add :start_hour, :integer, null: false, default: 9
      add :end_hour, :integer, null: false, default: 17
      add :slot_minutes, :integer, null: false, default: 60
      add :available_days, :string, null: false, default: ~s(["monday","tuesday","wednesday","thursday","friday"])

      timestamps(type: :utc_datetime)
    end
  end
end
