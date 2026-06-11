defmodule Innoso.Blog do
  import Ecto.Query, warn: false
  alias Innoso.Repo
  alias Innoso.Blog.Post

  def list_published_posts do
    Repo.all(
      from p in Post,
        where: not is_nil(p.published_at) and p.published_at <= ^DateTime.utc_now(),
        order_by: [desc: p.published_at]
    )
  end

  def list_all_posts do
    Repo.all(from p in Post, order_by: [desc: p.inserted_at])
  end

  def get_published_post_by_slug!(slug) do
    Repo.get_by!(Post, slug: slug)
  end

  def get_post!(id), do: Repo.get!(Post, id)

  def create_post(attrs) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post), do: Repo.delete(post)

  def change_post(%Post{} = post \\ %Post{}, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def published?(%Post{published_at: nil}), do: false
  def published?(%Post{published_at: dt}), do: DateTime.compare(dt, DateTime.utc_now()) != :gt

  def read_time(%Post{body: body}) when is_binary(body) do
    words = body |> String.split() |> length()
    max(1, div(words, 200))
  end

  def read_time(_), do: 1
end
