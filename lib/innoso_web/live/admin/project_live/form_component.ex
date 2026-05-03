defmodule InnosoWeb.Admin.ProjectLive.FormComponent do
  use InnosoWeb, :live_component

  alias Innoso.Portfolio

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header><%= @title %></.header>

      <.form for={@form} id="project-form" phx-target={@myself} phx-change="validate" phx-submit="save" class="space-y-4 mt-4">
        <.input field={@form[:name]} type="text" label="Project Name" required />
        <.input field={@form[:description]} type="textarea" label="Description" required />
        <.input field={@form[:cover_image]} type="text" label="Cover Image URL" placeholder="https://..." />
        <.input field={@form[:live_url]} type="text" label="Live URL" placeholder="https://..." />
        <.input field={@form[:client_type]} type="select" label="Client Type"
          options={[{"Business", "business"}, {"Government", "government"}, {"Organization", "organization"}, {"Personal", "personal"}]} />
        <.input field={@form[:tags]} type="text" label="Tags" placeholder="e.g. e-commerce, dashboard" />
        <.input field={@form[:demo_username]} type="text" label="Demo Username (optional)" />
        <.input field={@form[:demo_password]} type="text" label="Demo Password (optional)" />
        <.button class="btn btn-primary w-full" phx-disable-with="Saving...">Save Project</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{project: project} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn -> to_form(Portfolio.change_project(project)) end)}
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset = Portfolio.change_project(socket.assigns.project, project_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    save_project(socket, socket.assigns.action, project_params)
  end

  defp save_project(socket, :edit, project_params) do
    case Portfolio.update_project(socket.assigns.project, project_params) do
      {:ok, project} ->
        notify_parent({:saved, project})
        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")
         |> push_navigate(to: ~p"/admin/projects")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_project(socket, :new, project_params) do
    case Portfolio.create_project(project_params) do
      {:ok, project} ->
        notify_parent({:saved, project})
        {:noreply,
         socket
         |> put_flash(:info, "Project created successfully")
         |> push_navigate(to: ~p"/admin/projects")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
