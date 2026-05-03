defmodule Innoso.Team do
  import Ecto.Query, warn: false
  alias Innoso.Repo
  alias Innoso.Team.Member

  def list_members do
    Repo.all(from m in Member, order_by: [asc: m.sort_order, asc: m.inserted_at])
  end

  def get_member!(id), do: Repo.get!(Member, id)

  def create_member(attrs) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  def update_member(%Member{} = member, attrs) do
    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  def delete_member(%Member{} = member), do: Repo.delete(member)

  def change_member(%Member{} = member \\ %Member{}, attrs \\ %{}) do
    Member.changeset(member, attrs)
  end
end
