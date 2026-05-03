defmodule InnosoWeb.Admin.AdminUserLive.Index do
  use InnosoWeb, :live_view

  alias Innoso.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_scope={@current_scope}>
      <div class="p-8">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold">Admin Users</h1>
            <p class="text-base-content/60 text-sm mt-1">Manage who can access the admin panel</p>
          </div>
          <.link navigate={~p"/admin/admins/new"} class="btn btn-primary">
            <.icon name="hero-plus" class="size-4" /> Add Admin
          </.link>
        </div>

        <div class="card bg-base-100 shadow overflow-hidden">
          <div class="overflow-x-auto">
            <table class="table">
              <thead>
                <tr>
                  <th>Email</th>
                  <th>Created</th>
                  <th class="text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={admin <- @admins} id={"admin-#{admin.id}"}>
                  <td>
                    <div class="flex items-center gap-2">
                      <div class="w-8 h-8 bg-primary/10 rounded-full flex items-center justify-center">
                        <.icon name="hero-user" class="size-4 text-primary" />
                      </div>
                      <span class="font-medium"><%= admin.email %></span>
                      <span :if={admin.id == @current_scope.admin.id} class="badge badge-primary badge-xs">you</span>
                    </div>
                  </td>
                  <td class="text-sm text-base-content/60">
                    <%= Calendar.strftime(admin.inserted_at, "%B %d, %Y") %>
                  </td>
                  <td class="text-right">
                    <button :if={admin.id != @current_scope.admin.id}
                      phx-click="delete" phx-value-id={admin.id}
                      data-confirm={"Remove #{admin.email} from admin access?"}
                      class="btn btn-ghost btn-xs text-error">
                      Remove
                    </button>
                    <span :if={admin.id == @current_scope.admin.id} class="text-xs text-base-content/40">
                      (current user)
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <.modal :if={@live_action == :new} id="admin-modal" show on_cancel={JS.navigate(~p"/admin/admins")}>
        <.live_component
          module={InnosoWeb.Admin.AdminUserLive.FormComponent}
          id={:new}
          title="Add Admin"
          action={@live_action}
        />
      </.modal>
    </Layouts.admin>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :admins, Accounts.list_admins())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Admin Users")}
  end

  @impl true
  def handle_info({InnosoWeb.Admin.AdminUserLive.FormComponent, {:saved, _admin}}, socket) do
    {:noreply, assign(socket, :admins, Accounts.list_admins())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    admin = Accounts.get_admin!(String.to_integer(id))
    {:ok, _} = Accounts.delete_admin(admin)
    {:noreply, socket |> put_flash(:info, "Admin removed") |> assign(:admins, Accounts.list_admins())}
  end
end
