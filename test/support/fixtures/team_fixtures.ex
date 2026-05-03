defmodule Innoso.TeamFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Innoso.Team` context.
  """

  @doc """
  Generate a member.
  """
  def member_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name",
        photo: "some photo",
        role: "some role",
        sort_order: 42
      })

    {:ok, member} = Innoso.Team.create_member(attrs)
    member
  end
end
