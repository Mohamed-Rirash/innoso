defmodule Innoso.PortfolioFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Innoso.Portfolio` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        client_type: "some client_type",
        cover_image: "some cover_image",
        demo_password: "some demo_password",
        demo_username: "some demo_username",
        description: "some description",
        live_url: "some live_url",
        name: "some name",
        tags: "some tags"
      })

    {:ok, project} = Innoso.Portfolio.create_project(attrs)
    project
  end
end
