defmodule InnosoWeb.Admin.ProjectLive.FormComponent do
  use InnosoWeb, :live_component

  alias Innoso.Portfolio

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>{@title}</.header>

      <.form
        for={@form}
        id="project-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-4 mt-4"
      >
        <.input field={@form[:name]} type="text" label="Project Name" required />

        <%!-- Markdown description editor with Write / Preview tabs --%>
        <div>
          <div class="flex items-center justify-between mb-1.5">
            <label class="block text-sm font-semibold leading-6 text-base-content">
              Description <span class="text-error ml-0.5">*</span>
            </label>
            <div class="flex items-center gap-0.5 p-0.5 rounded-lg bg-black/[0.04] dark:bg-white/[0.06] border border-black/[0.07] dark:border-white/[0.08]">
              <button
                type="button"
                phx-click="switch_tab"
                phx-value-tab="write"
                phx-target={@myself}
                class={[
                  "flex items-center gap-1.5 text-xs font-bold px-3 py-1.5 rounded-md transition-all",
                  @desc_tab == :write && "bg-white dark:bg-base-100 shadow-sm text-base-content",
                  @desc_tab != :write && "text-base-content/45 hover:text-base-content"
                ]}
              >
                <.icon name="hero-pencil" class="size-3" /> Write
              </button>
              <button
                type="button"
                phx-click="switch_tab"
                phx-value-tab="preview"
                phx-target={@myself}
                class={[
                  "flex items-center gap-1.5 text-xs font-bold px-3 py-1.5 rounded-md transition-all",
                  @desc_tab == :preview && "bg-white dark:bg-base-100 shadow-sm text-base-content",
                  @desc_tab != :preview && "text-base-content/45 hover:text-base-content"
                ]}
              >
                <.icon name="hero-eye" class="size-3" /> Preview
              </button>
            </div>
          </div>

          <%!-- Textarea — always in DOM so the value is submitted with the form --%>
          <div class={[@desc_tab == :preview && "hidden"]}>
            <.input field={@form[:description]} type="textarea" label="" rows="10" required />
          </div>

          <%!-- Preview panel --%>
          <div :if={@desc_tab == :preview}>
            <div class={[
              "min-h-[220px] rounded-xl border border-black/[0.08] dark:border-white/[0.08]",
              "bg-white dark:bg-base-300 px-4 py-3 text-sm text-base-content/70 md-content",
              @desc_preview == "" && "flex items-center justify-center text-base-content/30 italic"
            ]}>
              <%= if @desc_preview == "" do %>
                Nothing to preview yet — write something first.
              <% else %>
                <%= Phoenix.HTML.raw(@desc_preview) %>
              <% end %>
            </div>
            <%!-- Keep the value in DOM for form submission when preview is shown --%>
            <input type="hidden" name={@form[:description].name} value={@form[:description].value} />
          </div>

          <p class="text-[11px] text-base-content/38 mt-1.5 flex items-center gap-1">
            <.icon name="hero-information-circle" class="size-3.5 shrink-0" />
            Supports Markdown: **bold**, *italic*, ## Heading, - list, [link](url), `code`
          </p>
        </div>
        <.input
          field={@form[:cover_image]}
          type="text"
          label="Cover Image URL"
          placeholder="https://..."
        />
        <.input field={@form[:live_url]} type="text" label="Live URL" placeholder="https://..." />
        <.input
          field={@form[:client_type]}
          type="select"
          label="Client Type"
          options={[
            {"Business", "business"},
            {"Government", "government"},
            {"Organization", "organization"},
            {"Personal", "personal"}
          ]}
        />
        <.input
          field={@form[:tags]}
          type="text"
          label="Tags"
          placeholder="e.g. e-commerce, dashboard"
        />

        <%!-- Demo Credentials --%>
        <div class="space-y-3">
          <div class="flex items-center justify-between">
            <label class="text-sm font-semibold text-base-content/70">Demo Credentials</label>
            <button
              type="button"
              phx-click="add_credential"
              phx-target={@myself}
              class="btn btn-xs btn-ghost gap-1 text-primary"
            >
              <.icon name="hero-plus" class="size-3.5" /> Add
            </button>
          </div>

          <div
            :if={@credentials == []}
            class="text-sm text-base-content/40 text-center py-4 rounded-xl border border-dashed border-black/[0.10] dark:border-white/[0.10]"
          >
            No credentials yet — click Add to create one
          </div>

          <form
            :if={@credentials != []}
            id="credentials-form"
            phx-change="update_credentials"
            phx-target={@myself}
            class="space-y-2"
          >
            <div
              :for={{cred, idx} <- Enum.with_index(@credentials)}
              class="relative rounded-xl border border-black/[0.08] dark:border-white/[0.08] bg-base-200/50 p-3 space-y-2"
            >
              <div class="flex items-center justify-between">
                <span class="text-[10px] font-black uppercase tracking-widest text-base-content/40">
                  Credential #{idx + 1}
                </span>
                <button
                  type="button"
                  phx-click="remove_credential"
                  phx-value-index={idx}
                  phx-target={@myself}
                  class="w-5 h-5 rounded flex items-center justify-center text-base-content/30 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 transition-all"
                >
                  <.icon name="hero-x-mark" class="size-3.5" />
                </button>
              </div>
              <input
                id={"cred-#{idx}-role"}
                name={"credentials[#{idx}][role]"}
                value={cred["role"]}
                placeholder="Role name (e.g. Admin, User, Manager)"
                class="input input-sm w-full rounded-lg text-sm"
              />
              <input
                id={"cred-#{idx}-username"}
                name={"credentials[#{idx}][username]"}
                value={cred["username"]}
                placeholder="Username or email"
                class="input input-sm w-full rounded-lg text-sm font-mono"
              />
              <input
                id={"cred-#{idx}-password"}
                name={"credentials[#{idx}][password]"}
                value={cred["password"]}
                placeholder="Password"
                class="input input-sm w-full rounded-lg text-sm font-mono"
              />
            </div>
          </form>
        </div>

        <.button class="btn btn-primary w-full" phx-disable-with="Saving...">Save Project</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{project: project} = assigns, socket) do
    credentials = project.demo_credentials || []

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:credentials, credentials)
     |> assign_new(:desc_tab, fn -> :write end)
     |> assign_new(:desc_preview, fn -> "" end)
     |> assign_new(:form, fn -> to_form(Portfolio.change_project(project)) end)}
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset = Portfolio.change_project(socket.assigns.project, project_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    project_params = Map.put(project_params, "demo_credentials", socket.assigns.credentials)
    save_project(socket, socket.assigns.action, project_params)
  end

  def handle_event("switch_tab", %{"tab" => "preview"}, socket) do
    description = socket.assigns.form[:description].value || ""
    html = InnosoWeb.Markdown.render(description)
    {:noreply, socket |> assign(:desc_tab, :preview) |> assign(:desc_preview, html)}
  end

  def handle_event("switch_tab", %{"tab" => "write"}, socket) do
    {:noreply, assign(socket, :desc_tab, :write)}
  end

  def handle_event("add_credential", _, socket) do
    creds = socket.assigns.credentials ++ [%{"role" => "", "username" => "", "password" => ""}]
    {:noreply, assign(socket, :credentials, creds)}
  end

  def handle_event("remove_credential", %{"index" => idx}, socket) do
    idx = String.to_integer(idx)
    creds = List.delete_at(socket.assigns.credentials, idx)
    {:noreply, assign(socket, :credentials, creds)}
  end

  def handle_event("update_credentials", params, socket) do
    credentials =
      case Map.get(params, "credentials", %{}) do
        creds_map when is_map(creds_map) ->
          creds_map
          |> Enum.sort_by(fn {k, _} -> String.to_integer(k) end)
          |> Enum.map(fn {_, v} -> v end)

        _ ->
          socket.assigns.credentials
      end

    {:noreply, assign(socket, :credentials, credentials)}
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
