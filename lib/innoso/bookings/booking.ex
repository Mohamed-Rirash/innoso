defmodule Innoso.Bookings.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :description, :string
    field :requested_date, :date
    field :requested_time, :time
    field :status, :string, default: "pending"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [
      :name,
      :email,
      :phone,
      :description,
      :requested_date,
      :requested_time,
      :status
    ])
    |> validate_required([:name, :email, :phone, :description, :requested_date, :requested_time])
    |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/, message: "must be a valid email")
    |> validate_length(:phone, min: 6, max: 20)
    |> validate_inclusion(:status, ~w(pending confirmed cancelled),
      message: "must be pending, confirmed, or cancelled"
    )
  end
end
