defmodule Innoso.Portfolio.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :description, :string
    field :cover_image, :string
    field :live_url, :string
    field :demo_username, :string
    field :demo_password, :string
    field :client_type, :string
    field :tags, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [
      :name,
      :description,
      :cover_image,
      :live_url,
      :demo_username,
      :demo_password,
      :client_type,
      :tags
    ])
    |> validate_required([:name, :description, :client_type])
    |> validate_length(:name, max: 255)
  end
end
