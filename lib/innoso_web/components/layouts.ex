defmodule InnosoWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use InnosoWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <a href="https://phoenixframework.org/" class="btn btn-ghost">Website</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix" class="btn btn-ghost">GitHub</a>
          </li>
          <li>
            <.theme_toggle />
          </li>
          <li>
            <a href="https://hexdocs.pm/phoenix/overview.html" class="btn btn-primary">
              Get Started <span aria-hidden="true">&rarr;</span>
            </a>
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Renders the admin panel layout with sidebar navigation.
  """
  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def admin(assigns) do
    ~H"""
    <div class="flex h-screen bg-base-200 overflow-hidden">
      <aside class="w-64 bg-base-100 border-r border-base-300 flex flex-col shrink-0">
        <div class="p-4 border-b border-base-300">
          <a href="/" class="flex items-center gap-2">
            <div class="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
              <span class="text-primary-content font-bold text-sm">I</span>
            </div>
            <span class="font-bold text-lg">Innoso</span>
          </a>
        </div>
        <nav class="flex-1 p-4 space-y-1">
          <.link
            navigate={~p"/admin"}
            class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-base-200 text-sm font-medium transition-colors"
          >
            <.icon name="hero-squares-2x2" class="size-5" /> Dashboard
          </.link>
          <.link
            navigate={~p"/admin/projects"}
            class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-base-200 text-sm font-medium transition-colors"
          >
            <.icon name="hero-briefcase" class="size-5" /> Projects
          </.link>
          <.link
            navigate={~p"/admin/team"}
            class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-base-200 text-sm font-medium transition-colors"
          >
            <.icon name="hero-users" class="size-5" /> Team
          </.link>
          <.link
            navigate={~p"/admin/bookings"}
            class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-base-200 text-sm font-medium transition-colors"
          >
            <.icon name="hero-calendar-days" class="size-5" /> Bookings
          </.link>
          <.link
            navigate={~p"/admin/admins"}
            class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-base-200 text-sm font-medium transition-colors"
          >
            <.icon name="hero-shield-check" class="size-5" /> Admins
          </.link>
        </nav>
        <div class="p-4 border-t border-base-300 space-y-1">
          <.link
            navigate={~p"/admin/settings"}
            class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-base-200 text-sm transition-colors"
          >
            <.icon name="hero-cog-6-tooth" class="size-5" /> Settings
          </.link>
          <.link
            href={~p"/admin/logout"}
            method="delete"
            class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-base-200 text-sm text-error transition-colors"
          >
            <.icon name="hero-arrow-right-on-rectangle" class="size-5" /> Logout
          </.link>
        </div>
      </aside>
      <main class="flex-1 overflow-y-auto">
        <.flash_group flash={@flash} />
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
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

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
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
