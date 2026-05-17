defmodule InnosoWeb.Admin.AdminUserLive.FormComponent do
  use InnosoWeb, :live_component

  alias Innoso.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>Add Admin User</.header>
      <.form
        for={@form}
        id="admin-user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-4 mt-4"
      >
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirm Password"
          required
        />
        <.button class="btn btn-primary w-full" phx-disable-with="Creating...">Create Admin</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(_assigns, socket) do
    {:ok,
     socket
     |> assign(:form, to_form(Accounts.change_admin_registration()))}
  end

  @impl true
  def handle_event("validate", %{"admin" => params}, socket) do
    changeset = Accounts.change_admin_registration(%Innoso.Accounts.Admin{}, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"admin" => params}, socket) do
    case Accounts.create_admin(params) do
      {:ok, admin} ->
        notify_parent({:saved, admin})

        {:noreply,
         socket
         |> put_flash(:info, "Admin #{admin.email} created")
         |> push_navigate(to: ~p"/admin/admins")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
