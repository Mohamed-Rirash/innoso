defmodule Innoso.Portfolio do
  import Ecto.Query, warn: false
  alias Innoso.Repo
  alias Innoso.Portfolio.Project

  def list_projects do
    Repo.all(from p in Project, order_by: [desc: p.inserted_at])
  end

  def get_project!(id), do: Repo.get!(Project, id)

  def create_project(attrs) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  def delete_project(%Project{} = project), do: Repo.delete(project)

  def change_project(%Project{} = project \\ %Project{}, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end
end
