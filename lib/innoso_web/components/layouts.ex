defmodule InnosoWeb.Layouts do
  @moduledoc false
  use InnosoWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>
    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Full-screen centered layout for admin auth pages (login, confirm, register).
  """
  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def auth(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100 relative flex items-center justify-center p-4 overflow-hidden">
      <%!-- Background orbs --%>
      <div aria-hidden="true" class="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
        <div class="absolute -top-[300px] -left-[200px] w-[700px] h-[700px] rounded-full bg-violet-600/8 dark:bg-violet-500/15 blur-[140px]"></div>
        <div class="absolute -bottom-[200px] -right-[100px] w-[600px] h-[600px] rounded-full bg-indigo-500/6 dark:bg-blue-500/12 blur-[120px]"></div>
      </div>

      <div class="w-full max-w-sm">
        <%!-- Logo --%>
        <div class="flex items-center justify-center gap-3 mb-8">
          <div class="w-10 h-10 rounded-2xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-lg shadow-primary/30">
            <span class="text-white font-black text-sm select-none tracking-tight">IN</span>
          </div>
          <span class="font-black text-2xl tracking-tight">Innoso</span>
        </div>

        <%!-- Flash messages --%>
        <.flash_group flash={@flash} />

        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc """
  Admin panel layout with sidebar navigation. Pass `current_path` for active highlighting.
  """
  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  attr :current_path, :string, default: ""
  slot :inner_block, required: true

  def admin(assigns) do
    ~H"""
    <div class="flex h-screen bg-base-200 overflow-hidden">
      <%!-- Sidebar --%>
      <aside class="w-60 bg-base-100 border-r border-base-300 flex flex-col shrink-0">
        <%!-- Logo --%>
        <div class="h-14 px-4 flex items-center border-b border-base-300 shrink-0">
          <a href="/" class="flex items-center gap-2.5 group">
            <div class="w-7 h-7 rounded-lg bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-sm shadow-primary/25 group-hover:scale-105 transition-transform">
              <span class="text-white font-black text-xs select-none">IN</span>
            </div>
            <span class="font-black text-base tracking-tight">Innoso</span>
          </a>
        </div>

        <%!-- Nav --%>
        <nav class="flex-1 p-3 space-y-0.5 overflow-y-auto">
          <.admin_nav_link
            path={~p"/admin"}
            current_path={@current_path}
            icon="hero-squares-2x2"
            exact
          >
            Dashboard
          </.admin_nav_link>
          <.admin_nav_link path={~p"/admin/projects"} current_path={@current_path} icon="hero-briefcase">
            Projects
          </.admin_nav_link>
          <.admin_nav_link path={~p"/admin/team"} current_path={@current_path} icon="hero-users">
            Team
          </.admin_nav_link>
          <.admin_nav_link
            path={~p"/admin/bookings"}
            current_path={@current_path}
            icon="hero-calendar-days"
          >
            Bookings
          </.admin_nav_link>
          <.admin_nav_link
            path={~p"/admin/blog"}
            current_path={@current_path}
            icon="hero-pencil-square"
          >
            Blog
          </.admin_nav_link>
          <.admin_nav_link
            path={~p"/admin/scheduling"}
            current_path={@current_path}
            icon="hero-clock"
          >
            Scheduling
          </.admin_nav_link>
          <.admin_nav_link
            path={~p"/admin/admins"}
            current_path={@current_path}
            icon="hero-shield-check"
          >
            Admins
          </.admin_nav_link>
        </nav>

        <%!-- Footer --%>
        <div class="p-3 border-t border-base-300 space-y-0.5">
          <.admin_nav_link
            path={~p"/admin/settings"}
            current_path={@current_path}
            icon="hero-cog-6-tooth"
          >
            Settings
          </.admin_nav_link>
          <.link
            href={~p"/admin/logout"}
            method="delete"
            class="flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm font-medium text-error/80 hover:text-error hover:bg-error/8 transition-all"
          >
            <.icon name="hero-arrow-right-on-rectangle" class="size-4 shrink-0" /> Logout
          </.link>
        </div>
      </aside>

      <%!-- Main content --%>
      <div class="flex-1 flex flex-col min-w-0 overflow-hidden">
        <%!-- Top bar --%>
        <header class="h-14 bg-base-100 border-b border-base-300 px-6 flex items-center justify-between shrink-0">
          <div class="flex items-center gap-2 text-base-content/40 text-xs">
            <.icon name="hero-lock-closed" class="size-3" />
            <span>Admin Panel</span>
          </div>
          <div class="flex items-center gap-3">
            <a
              href="/"
              target="_blank"
              class="btn btn-ghost btn-xs gap-1.5 text-base-content/50 hover:text-base-content"
            >
              <.icon name="hero-arrow-top-right-on-square" class="size-3.5" /> View site
            </a>
            <div :if={@current_scope} class="flex items-center gap-2 text-sm">
              <div class="w-7 h-7 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center">
                <.icon name="hero-user" class="size-3.5 text-primary" />
              </div>
              <span class="text-base-content/60 text-xs max-w-32 truncate hidden sm:block">
                {@current_scope.admin.email}
              </span>
            </div>
          </div>
        </header>

        <%!-- Page content --%>
        <main class="flex-1 overflow-y-auto bg-base-200">
          <.flash_group flash={@flash} />
          {render_slot(@inner_block)}
        </main>
      </div>
    </div>
    """
  end

  attr :path, :string, required: true
  attr :current_path, :string, required: true
  attr :icon, :string, required: true
  attr :exact, :boolean, default: false
  slot :inner_block, required: true

  defp admin_nav_link(assigns) do
    ~H"""
    <.link
      navigate={@path}
      class={[
        "flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm font-medium transition-all",
        if(nav_active?(@current_path, @path, @exact),
          do:
            "bg-primary/10 text-primary border border-primary/15 dark:bg-primary/15 dark:border-primary/20",
          else: "text-base-content/65 hover:text-base-content hover:bg-base-200"
        )
      ]}
    >
      <.icon name={@icon} class="size-4 shrink-0" />
      {render_slot(@inner_block)}
    </.link>
    """
  end

  defp nav_active?(current_path, path, exact) do
    if exact do
      current_path == path
    else
      current_path == path or String.starts_with?(current_path, path <> "/")
    end
  end

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
