defmodule InnosoWeb.Admin.ProjectLive.Index do
  use InnosoWeb, :live_view

  alias Innoso.Portfolio
  alias Innoso.Portfolio.Project

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_scope={@current_scope}>
      <div class="p-8">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold">Projects</h1>
            <p class="text-base-content/60 text-sm mt-1">Manage your showcased projects</p>
          </div>
          <.link navigate={~p"/admin/projects/new"} class="btn btn-primary">
            <.icon name="hero-plus" class="size-4" /> New Project
          </.link>
        </div>

        <div :if={@projects == []} class="card bg-base-100 shadow">
          <div class="card-body items-center text-center py-16">
            <.icon name="hero-briefcase" class="size-12 text-base-content/30" />
            <p class="text-base-content/60 mt-2">No projects yet. Add your first project.</p>
            <.link navigate={~p"/admin/projects/new"} class="btn btn-primary mt-4">
              Add Project
            </.link>
          </div>
        </div>

        <div :if={@projects != []} class="card bg-base-100 shadow overflow-hidden">
          <div class="overflow-x-auto">
            <table class="table table-zebra">
              <thead>
                <tr>
                  <th>Project</th>
                  <th>Client Type</th>
                  <th>Tags</th>
                  <th>Live URL</th>
                  <th class="text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={project <- @projects} id={"project-#{project.id}"}>
                  <td>
                    <div class="flex items-center gap-3">
                      <div :if={project.cover_image} class="avatar">
                        <div class="w-10 rounded">
                          <img src={project.cover_image} alt={project.name} />
                        </div>
                      </div>
                      <div>
                        <div class="font-medium">{project.name}</div>
                        <div class="text-xs text-base-content/60 max-w-xs truncate">
                          {project.description}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <span class="badge badge-outline badge-sm">{project.client_type}</span>
                  </td>
                  <td class="text-sm text-base-content/60">{project.tags}</td>
                  <td>
                    <a
                      :if={project.live_url}
                      href={project.live_url}
                      target="_blank"
                      class="link link-primary text-sm"
                    >
                      View →
                    </a>
                  </td>
                  <td class="text-right">
                    <div class="flex gap-2 justify-end">
                      <.link
                        navigate={~p"/admin/projects/#{project.id}/edit"}
                        class="btn btn-ghost btn-xs"
                      >
                        Edit
                      </.link>
                      <button
                        phx-click="delete"
                        phx-value-id={project.id}
                        data-confirm="Delete this project?"
                        class="btn btn-ghost btn-xs text-error"
                      >
                        Delete
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <.modal
        :if={@live_action in [:new, :edit]}
        id="project-modal"
        show
        on_cancel={JS.navigate(~p"/admin/projects")}
      >
        <.live_component
          module={InnosoWeb.Admin.ProjectLive.FormComponent}
          id={@project.id || :new}
          title={@page_title}
          action={@live_action}
          project={@project}
        />
      </.modal>
    </Layouts.admin>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :projects, Portfolio.list_projects())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, Portfolio.get_project!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_info({InnosoWeb.Admin.ProjectLive.FormComponent, {:saved, _project}}, socket) do
    {:noreply, assign(socket, :projects, Portfolio.list_projects())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Portfolio.get_project!(id)
    {:ok, _} = Portfolio.delete_project(project)
    {:noreply, assign(socket, :projects, Portfolio.list_projects())}
  end
end
