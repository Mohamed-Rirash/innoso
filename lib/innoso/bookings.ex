defmodule Innoso.Bookings do
  import Ecto.Query, warn: false
  alias Innoso.Repo
  alias Innoso.Bookings.Booking

  def list_bookings do
    Repo.all(from b in Booking, order_by: [asc: b.requested_date, asc: b.requested_time])
  end

  def list_pending_bookings do
    Repo.all(from b in Booking, where: b.status == "pending", order_by: [asc: b.requested_date])
  end

  def get_booking!(id), do: Repo.get!(Booking, id)

  def create_booking(attrs) do
    %Booking{}
    |> Booking.changeset(attrs)
    |> Repo.insert()
  end

  def update_booking(%Booking{} = booking, attrs) do
    booking
    |> Booking.changeset(attrs)
    |> Repo.update()
  end

  def confirm_booking(%Booking{} = booking) do
    update_booking(booking, %{status: "confirmed"})
  end

  def cancel_booking(%Booking{} = booking) do
    update_booking(booking, %{status: "cancelled"})
  end

  def delete_booking(%Booking{} = booking), do: Repo.delete(booking)

  def change_booking(%Booking{} = booking \\ %Booking{}, attrs \\ %{}) do
    Booking.changeset(booking, attrs)
  end

  def slot_taken?(date, time) do
    Repo.exists?(
      from b in Booking,
        where: b.requested_date == ^date and b.requested_time == ^time and b.status == "confirmed"
    )
  end
end
