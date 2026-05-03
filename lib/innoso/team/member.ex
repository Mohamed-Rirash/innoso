defmodule Innoso.Team.Member do
  use Ecto.Schema
  import Ecto.Changeset

  schema "members" do
    field :name, :string
    field :role, :string
    field :photo, :string
    field :sort_order, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:name, :role, :photo, :sort_order])
    |> validate_required([:name, :role])
    |> validate_length(:name, max: 255)
    |> validate_length(:role, max: 255)
  end
end
