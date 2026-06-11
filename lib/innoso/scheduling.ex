defmodule Innoso.Scheduling do
  import Ecto.Query, warn: false
  alias Innoso.Repo
  alias Innoso.Bookings
  alias Innoso.Scheduling.Config

  @default_config %{
    available_days: ~w(monday tuesday wednesday thursday friday),
    start_hour: 9,
    end_hour: 17,
    slot_minutes: 60
  }

  def available_slots_for_weeks(weeks \\ 2) do
    today = Date.utc_today()
    config = get_config()

    0..(weeks * 7 - 1)
    |> Enum.map(&Date.add(today, &1))
    |> Enum.filter(&available_day?(&1, config))
    |> Enum.flat_map(&slots_for_date(&1, config))
  end

  def slots_for_date(date, config \\ nil) do
    config = config || get_config()

    config.start_hour
    |> Stream.iterate(&(&1 + div(config.slot_minutes, 60)))
    |> Enum.take_while(&(&1 < config.end_hour))
    |> Enum.map(fn hour ->
      time = Time.new!(hour, 0, 0)
      %{date: date, time: time, taken: Bookings.slot_taken?(date, time)}
    end)
  end

  def get_config do
    case Repo.one(Config) do
      nil -> struct(Config, @default_config)
      config -> config
    end
  end

  def get_or_create_config do
    case Repo.one(Config) do
      nil ->
        %Config{}
        |> Config.changeset(Map.new(@default_config, fn {k, v} -> {Atom.to_string(k), v} end))
        |> Repo.insert()

      config ->
        {:ok, config}
    end
  end

  def update_config(%Config{} = config, attrs) do
    config
    |> Config.changeset(attrs)
    |> Repo.update()
  end

  def change_config(%Config{} = config, attrs \\ %{}) do
    Config.changeset(config, attrs)
  end

  defp available_day?(date, config) do
    day_name = date |> Date.day_of_week() |> day_number_to_name()
    day_name in config.available_days
  end

  defp day_number_to_name(1), do: "monday"
  defp day_number_to_name(2), do: "tuesday"
  defp day_number_to_name(3), do: "wednesday"
  defp day_number_to_name(4), do: "thursday"
  defp day_number_to_name(5), do: "friday"
  defp day_number_to_name(6), do: "saturday"
  defp day_number_to_name(7), do: "sunday"
end
