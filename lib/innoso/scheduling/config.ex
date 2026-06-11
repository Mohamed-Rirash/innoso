defmodule Innoso.Scheduling.Config do
  use Ecto.Schema
  import Ecto.Changeset

  @weekdays ~w(monday tuesday wednesday thursday friday saturday sunday)

  schema "scheduling_configs" do
    field :start_hour, :integer, default: 9
    field :end_hour, :integer, default: 17
    field :slot_minutes, :integer, default: 60
    field :available_days, {:array, :string}, default: ~w(monday tuesday wednesday thursday friday)

    timestamps(type: :utc_datetime)
  end

  def changeset(config, attrs) do
    config
    |> cast(attrs, [:start_hour, :end_hour, :slot_minutes, :available_days])
    |> validate_required([:start_hour, :end_hour, :slot_minutes, :available_days])
    |> validate_number(:start_hour, greater_than_or_equal_to: 0, less_than: 24)
    |> validate_number(:end_hour, greater_than_or_equal_to: 1, less_than_or_equal_to: 24)
    |> validate_number(:slot_minutes, greater_than: 0)
    |> validate_subset(:available_days, @weekdays)
    |> validate_end_after_start()
  end

  defp validate_end_after_start(changeset) do
    start = get_field(changeset, :start_hour)
    finish = get_field(changeset, :end_hour)

    if start && finish && finish <= start do
      add_error(changeset, :end_hour, "must be after start hour")
    else
      changeset
    end
  end
end
