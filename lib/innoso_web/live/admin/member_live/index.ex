defmodule InnosoWeb.Admin.MemberLive.Index do
  use InnosoWeb, :live_view

  alias Innoso.Team
  alias Innoso.Team.Member

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_scope={@current_scope} current_path={@current_path}>
      <div class="p-8">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold">Team Members</h1>
            <p class="text-base-content/60 text-sm mt-1">Manage your team displayed on the site</p>
          </div>
          <.link navigate={~p"/admin/team/new"} class="btn btn-primary">
            <.icon name="hero-plus" class="size-4" /> Add Member
          </.link>
        </div>

        <div :if={@members == []} class="card bg-base-100 shadow">
          <div class="card-body items-center text-center py-16">
            <.icon name="hero-users" class="size-12 text-base-content/30" />
            <p class="text-base-content/60 mt-2">No team members yet.</p>
            <.link navigate={~p"/admin/team/new"} class="btn btn-primary mt-4">Add Member</.link>
          </div>
        </div>

        <div :if={@members != []} class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <div :for={member <- @members} id={"member-#{member.id}"} class="card bg-base-100 shadow">
            <div class="card-body items-center text-center">
              <div class="avatar mb-2">
                <div class="w-20 rounded-full bg-base-200">
                  <img :if={member.photo} src={member.photo} alt={member.name} />
                  <div :if={!member.photo} class="flex items-center justify-center h-full">
                    <.icon name="hero-user" class="size-10 text-base-content/30" />
                  </div>
                </div>
              </div>
              <h3 class="font-semibold">{member.name}</h3>
              <p class="text-sm text-base-content/60">{member.role}</p>
              <div class="card-actions mt-2">
                <.link navigate={~p"/admin/team/#{member.id}/edit"} class="btn btn-ghost btn-xs">
                  Edit
                </.link>
                <button
                  phx-click="delete"
                  phx-value-id={member.id}
                  data-confirm="Remove this team member?"
                  class="btn btn-ghost btn-xs text-error"
                >
                  Remove
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <.modal
        :if={@live_action in [:new, :edit]}
        id="member-modal"
        show
        on_cancel={JS.navigate(~p"/admin/team")}
      >
        <.live_component
          module={InnosoWeb.Admin.MemberLive.FormComponent}
          id={@member.id || :new}
          title={@page_title}
          action={@live_action}
          member={@member}
        />
      </.modal>
    </Layouts.admin>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :members, Team.list_members())}
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply,
     socket
     |> assign(:current_path, URI.parse(url).path)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket |> assign(:page_title, "Edit Member") |> assign(:member, Team.get_member!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket |> assign(:page_title, "Add Member") |> assign(:member, %Member{})
  end

  defp apply_action(socket, :index, _params) do
    socket |> assign(:page_title, "Team") |> assign(:member, nil)
  end

  @impl true
  def handle_info({InnosoWeb.Admin.MemberLive.FormComponent, {:saved, _member}}, socket) do
    {:noreply, assign(socket, :members, Team.list_members())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    member = Team.get_member!(id)
    {:ok, _} = Team.delete_member(member)
    {:noreply, assign(socket, :members, Team.list_members())}
  end
end
