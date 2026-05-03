defmodule Innoso.TeamTest do
  use Innoso.DataCase

  alias Innoso.Team
  alias Innoso.Team.Member

  @valid_attrs %{name: "Alice Dev", role: "Full Stack Developer", sort_order: 1}
  @update_attrs %{name: "Alice Smith", role: "Lead Developer", sort_order: 0}

  test "list_members/0 returns all members ordered by sort_order" do
    {:ok, member} = Team.create_member(@valid_attrs)
    assert Enum.any?(Team.list_members(), &(&1.id == member.id))
  end

  test "get_member!/1 returns the member" do
    {:ok, member} = Team.create_member(@valid_attrs)
    assert Team.get_member!(member.id) == member
  end

  test "create_member/1 with valid data creates a member" do
    assert {:ok, %Member{} = member} = Team.create_member(@valid_attrs)
    assert member.name == "Alice Dev"
    assert member.role == "Full Stack Developer"
  end

  test "create_member/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Team.create_member(%{name: nil, role: nil})
  end

  test "update_member/2 with valid data updates the member" do
    {:ok, member} = Team.create_member(@valid_attrs)
    assert {:ok, %Member{} = updated} = Team.update_member(member, @update_attrs)
    assert updated.name == "Alice Smith"
  end

  test "delete_member/1 deletes the member" do
    {:ok, member} = Team.create_member(@valid_attrs)
    assert {:ok, _} = Team.delete_member(member)
    assert_raise Ecto.NoResultsError, fn -> Team.get_member!(member.id) end
  end

  test "change_member/1 returns a changeset" do
    assert %Ecto.Changeset{} = Team.change_member()
  end
end
