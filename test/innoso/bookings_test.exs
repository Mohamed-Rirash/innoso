defmodule Innoso.BookingsTest do
  use Innoso.DataCase

  alias Innoso.Bookings
  alias Innoso.Bookings.Booking

  @valid_attrs %{
    name: "John Doe",
    email: "john@example.com",
    phone: "+252612345678",
    description: "Need a web app",
    requested_date: ~D[2026-06-01],
    requested_time: ~T[09:00:00],
    status: "pending"
  }

  test "list_bookings/0 returns all bookings" do
    {:ok, booking} = Bookings.create_booking(@valid_attrs)
    assert Bookings.list_bookings() == [booking]
  end

  test "get_booking!/1 returns the booking" do
    {:ok, booking} = Bookings.create_booking(@valid_attrs)
    assert Bookings.get_booking!(booking.id) == booking
  end

  test "create_booking/1 with valid data creates a booking" do
    assert {:ok, %Booking{} = booking} = Bookings.create_booking(@valid_attrs)
    assert booking.name == "John Doe"
    assert booking.status == "pending"
  end

  test "create_booking/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Bookings.create_booking(%{name: nil})
  end

  test "confirm_booking/1 sets status confirmed" do
    {:ok, booking} = Bookings.create_booking(@valid_attrs)
    assert {:ok, updated} = Bookings.confirm_booking(booking)
    assert updated.status == "confirmed"
  end

  test "cancel_booking/1 sets status cancelled" do
    {:ok, booking} = Bookings.create_booking(@valid_attrs)
    assert {:ok, updated} = Bookings.cancel_booking(booking)
    assert updated.status == "cancelled"
  end

  test "delete_booking/1 deletes the booking" do
    {:ok, booking} = Bookings.create_booking(@valid_attrs)
    assert {:ok, _} = Bookings.delete_booking(booking)
    assert_raise Ecto.NoResultsError, fn -> Bookings.get_booking!(booking.id) end
  end

  test "change_booking/1 returns a changeset" do
    assert %Ecto.Changeset{} = Bookings.change_booking()
  end
end
