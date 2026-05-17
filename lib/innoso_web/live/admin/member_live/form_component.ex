defmodule InnosoWeb.Admin.MemberLive.FormComponent do
  use InnosoWeb, :live_component

  alias Innoso.Team

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>{@title}</.header>
      <.form
        for={@form}
        id="member-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-4 mt-4"
      >
        <.input field={@form[:name]} type="text" label="Full Name" required />
        <.input field={@form[:role]} type="text" label="Role / Title" required />
        <.input field={@form[:photo]} type="text" label="Photo URL" placeholder="https://..." />
        <.input field={@form[:sort_order]} type="number" label="Sort Order" />
        <.button class="btn btn-primary w-full" phx-disable-with="Saving...">Save Member</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{member: member} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn -> to_form(Team.change_member(member)) end)}
  end

  @impl true
  def handle_event("validate", %{"member" => params}, socket) do
    changeset = Team.change_member(socket.assigns.member, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"member" => params}, socket) do
    save_member(socket, socket.assigns.action, params)
  end

  defp save_member(socket, :edit, params) do
    case Team.update_member(socket.assigns.member, params) do
      {:ok, member} ->
        notify_parent({:saved, member})

        {:noreply,
         socket |> put_flash(:info, "Member updated") |> push_navigate(to: ~p"/admin/team")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_member(socket, :new, params) do
    case Team.create_member(params) do
      {:ok, member} ->
        notify_parent({:saved, member})

        {:noreply,
         socket |> put_flash(:info, "Member added") |> push_navigate(to: ~p"/admin/team")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
