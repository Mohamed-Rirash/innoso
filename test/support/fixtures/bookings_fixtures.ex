defmodule Innoso.BookingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Innoso.Bookings` context.
  """

  @doc """
  Generate a booking.
  """
  def booking_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        email: "some email",
        name: "some name",
        phone: "some phone",
        requested_date: ~D[2026-05-02],
        requested_time: ~T[14:00:00],
        status: "some status"
      })

    {:ok, booking} = Innoso.Bookings.create_booking(attrs)
    booking
  end
end
