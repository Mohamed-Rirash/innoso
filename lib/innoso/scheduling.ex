defmodule Innoso.Scheduling do
  alias Innoso.Bookings

  @weekdays ~w(monday tuesday wednesday thursday friday)

  def available_slots_for_weeks(weeks \\ 2) do
    today = Date.utc_today()

    0..(weeks * 7 - 1)
    |> Enum.map(&Date.add(today, &1))
    |> Enum.filter(&available_day?/1)
    |> Enum.flat_map(&slots_for_date/1)
  end

  def slots_for_date(date) do
    config = scheduling_config()
    start_hour = config[:start_hour]
    end_hour = config[:end_hour]
    slot_minutes = config[:slot_minutes]

    start_hour
    |> Stream.iterate(&(&1 + div(slot_minutes, 60)))
    |> Enum.take_while(&(&1 < end_hour))
    |> Enum.map(fn hour ->
      time = Time.new!(hour, 0, 0)
      %{date: date, time: time, taken: Bookings.slot_taken?(date, time)}
    end)
  end

  defp available_day?(date) do
    config = scheduling_config()
    day_name = date |> Date.day_of_week() |> day_number_to_name()
    day_name in config[:available_days]
  end

  defp day_number_to_name(1), do: "monday"
  defp day_number_to_name(2), do: "tuesday"
  defp day_number_to_name(3), do: "wednesday"
  defp day_number_to_name(4), do: "thursday"
  defp day_number_to_name(5), do: "friday"
  defp day_number_to_name(6), do: "saturday"
  defp day_number_to_name(7), do: "sunday"

  defp scheduling_config do
    Application.get_env(:innoso, :scheduling,
      available_days: @weekdays,
      start_hour: 9,
      end_hour: 17,
      slot_minutes: 60
    )
  end
end
