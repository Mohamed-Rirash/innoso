defmodule Innoso.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :slug, :string
    field :body, :string
    field :excerpt, :string
    field :cover_image, :string
    field :published_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :slug, :body, :excerpt, :cover_image, :published_at])
    |> validate_required([:title, :slug, :body])
    |> validate_length(:title, max: 255)
    |> validate_length(:slug, max: 255)
    |> update_change(:slug, &slugify/1)
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/, message: "only lowercase letters, numbers, and hyphens")
    |> unique_constraint(:slug)
  end

  def slugify(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^\w\s-]/u, "")
    |> String.replace(~r/[\s_]+/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.trim("-")
  end
end
