defmodule Innoso.PortfolioTest do
  use Innoso.DataCase

  alias Innoso.Portfolio
  alias Innoso.Portfolio.Project

  @valid_attrs %{name: "Test Project", description: "A great project", client_type: "business"}
  @update_attrs %{name: "Updated Project", description: "Updated desc", client_type: "government"}

  test "list_projects/0 returns all projects" do
    {:ok, project} = Portfolio.create_project(@valid_attrs)
    projects = Portfolio.list_projects()
    assert Enum.any?(projects, &(&1.id == project.id))
  end

  test "get_project!/1 returns the project" do
    {:ok, project} = Portfolio.create_project(@valid_attrs)
    assert Portfolio.get_project!(project.id) == project
  end

  test "create_project/1 with valid data creates a project" do
    assert {:ok, %Project{} = project} = Portfolio.create_project(@valid_attrs)
    assert project.name == "Test Project"
    assert project.client_type == "business"
  end

  test "create_project/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} =
             Portfolio.create_project(%{name: nil, client_type: nil, description: nil})
  end

  test "update_project/2 with valid data updates the project" do
    {:ok, project} = Portfolio.create_project(@valid_attrs)
    assert {:ok, %Project{} = updated} = Portfolio.update_project(project, @update_attrs)
    assert updated.name == "Updated Project"
  end

  test "delete_project/1 deletes the project" do
    {:ok, project} = Portfolio.create_project(@valid_attrs)
    assert {:ok, _} = Portfolio.delete_project(project)
    assert_raise Ecto.NoResultsError, fn -> Portfolio.get_project!(project.id) end
  end

  test "change_project/1 returns a changeset" do
    assert %Ecto.Changeset{} = Portfolio.change_project()
  end
end
