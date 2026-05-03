defmodule Innoso.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings) do
      add :name, :string
      add :email, :string
      add :phone, :string
      add :description, :text
      add :requested_date, :date
      add :requested_time, :time
      add :status, :string, default: "pending", null: false

      timestamps(type: :utc_datetime)
    end
  end
end
