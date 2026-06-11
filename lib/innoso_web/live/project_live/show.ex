defmodule InnosoWeb.ProjectLive.Show do
  use InnosoWeb, :live_view

  alias Innoso.Portfolio

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    project = Portfolio.get_project!(id)
    others = Portfolio.list_projects() |> Enum.reject(&(&1.id == project.id)) |> Enum.take(3)

    tags =
      if project.tags,
        do:
          project.tags
          |> String.split(",")
          |> Enum.map(&String.trim/1)
          |> Enum.reject(&(&1 == "")),
        else: []

    credentials =
      (project.demo_credentials || [])
      |> Enum.reject(fn c -> c["username"] == nil and c["password"] == nil end)

    {:ok,
     socket
     |> assign(:project, project)
     |> assign(:others, others)
     |> assign(:tags, tags)
     |> assign(:credentials, credentials)
     |> assign(:description_html, InnosoWeb.Markdown.render(project.description))
     |> assign(:page_title, project.name <> " — Innoso")
     |> assign(:page_description, project.description |> InnosoWeb.Markdown.plain_text() |> String.slice(0, 160))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100 antialiased">

      <%!-- ═══ NAVBAR ═══ --%>
      <nav class="sticky top-0 z-50 bg-white/80 dark:bg-base-100/80 backdrop-blur-xl border-b border-black/[0.07] dark:border-white/[0.07] px-4 sm:px-6 lg:px-8">
        <div class="max-w-6xl mx-auto h-14 flex items-center justify-between">
          <.link navigate={~p"/#projects"} class="flex items-center gap-2 text-sm font-semibold text-base-content/50 hover:text-base-content transition-colors group">
            <.icon name="hero-arrow-left" class="size-4 group-hover:-translate-x-0.5 transition-transform" />
            {gettext("Portfolio")}
          </.link>
          <.link navigate={~p"/"} class="flex items-center gap-2 group">
            <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-sm shadow-primary/20 group-hover:scale-105 transition-transform">
              <span class="text-white font-black text-xs select-none">IN</span>
            </div>
            <span class="font-black text-base tracking-tight">Innoso</span>
          </.link>
          <a href="/#booking" class="btn btn-sm rounded-xl font-bold px-4 bg-gradient-to-r from-primary to-secondary text-white border-0 shadow-md shadow-primary/20 hover:opacity-90 transition-all text-xs">
            {gettext("Book a Call")}
          </a>
        </div>
      </nav>

      <%!-- ═══ FULL-BLEED HERO ═══ --%>
      <div class="relative h-[65vh] min-h-[400px] max-h-[640px] overflow-hidden bg-gray-950">
        <img
          :if={@project.cover_image}
          src={@project.cover_image}
          alt={@project.name}
          class="absolute inset-0 w-full h-full object-cover opacity-80"
        />
        <div
          :if={!@project.cover_image}
          class="absolute inset-0 bg-gradient-to-br from-primary/30 via-violet-900/40 to-secondary/25"
        ></div>

        <%!-- Multi-layer gradient for readability --%>
        <div class="absolute inset-0 bg-gradient-to-t from-black via-black/40 to-transparent"></div>
        <div class="absolute inset-0 bg-gradient-to-r from-black/50 to-transparent"></div>

        <%!-- Top badges --%>
        <div class="absolute top-6 left-6 right-6 flex items-start justify-between">
          <span class="text-[11px] font-black uppercase tracking-[0.15em] px-3.5 py-1.5 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 text-white/80 capitalize">
            {@project.client_type}
          </span>
          <div class="flex items-center gap-2">
            <span :if={@project.live_url} class="flex items-center gap-1.5 text-[11px] font-bold px-3 py-1.5 rounded-full bg-emerald-500/90 backdrop-blur-sm text-white">
              <span class="w-1.5 h-1.5 rounded-full bg-white animate-pulse"></span>
              {gettext("Live")}
            </span>
            <span :if={@credentials != []} class="text-[11px] font-bold px-3 py-1.5 rounded-full bg-amber-500/90 backdrop-blur-sm text-white">
              {gettext("Demo")}
            </span>
          </div>
        </div>

        <%!-- Bottom: title + excerpt --%>
        <div class="absolute bottom-0 left-0 right-0 px-6 sm:px-10 lg:px-16 pb-10 sm:pb-14">
          <div class="max-w-6xl mx-auto">
            <div class="max-w-3xl">
              <h1 class="text-3xl sm:text-5xl lg:text-6xl font-black text-white leading-[1.05] tracking-tight mb-4">
                {@project.name}
              </h1>
              <p :if={@project.description} class="text-white/55 text-sm sm:text-base leading-relaxed line-clamp-2 max-w-2xl">
                {InnosoWeb.Markdown.plain_text(@project.description) |> String.slice(0, 180)}
              </p>
            </div>
          </div>
        </div>
      </div>

      <%!-- ═══ TECH OVERVIEW STRIP ═══ --%>
      <div :if={@tags != []} class="border-b border-black/[0.07] dark:border-white/[0.07] bg-white dark:bg-base-200">
        <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center gap-3 overflow-x-auto">
          <span class="text-[10px] font-black text-base-content/30 uppercase tracking-widest shrink-0">Stack</span>
          <span class="h-3 w-px bg-black/[0.10] dark:bg-white/[0.10] shrink-0"></span>
          <div class="flex items-center gap-2 flex-nowrap">
            <span
              :for={tag <- @tags}
              class="text-xs font-semibold px-3 py-1 rounded-full bg-primary/8 dark:bg-primary/12 text-primary border border-primary/15 dark:border-primary/20 whitespace-nowrap shrink-0"
            >
              {tag}
            </span>
          </div>
        </div>
      </div>

      <%!-- ═══ MAIN CONTENT ═══ --%>
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-14 lg:py-20">
        <div class="grid lg:grid-cols-[1fr_320px] gap-12 lg:gap-16">

          <%!-- ── LEFT: Main content ── --%>
          <div class="min-w-0">

            <%!-- Section 01 — Overview --%>
            <div class="mb-16">
              <div class="flex items-center gap-4 mb-8">
                <span class="text-5xl font-black text-base-content/[0.06] dark:text-base-content/[0.05] leading-none select-none font-mono">01</span>
                <div>
                  <p class="text-[10px] font-black text-primary/70 uppercase tracking-[0.18em] mb-0.5">Case Study</p>
                  <h2 class="text-xl font-black">{gettext("Project Overview")}</h2>
                </div>
              </div>
              <div class="pl-0 sm:pl-[72px]">
                <div class="prose prose-base max-w-none text-base-content/65 leading-[1.85] md-content [&_h1]:text-2xl [&_h1]:font-black [&_h1]:text-base-content [&_h2]:text-xl [&_h2]:font-black [&_h2]:text-base-content [&_h3]:text-lg [&_h3]:font-black [&_h3]:text-base-content [&_strong]:text-base-content [&_strong]:font-bold [&_a]:text-primary [&_code]:text-primary [&_code]:bg-primary/8 [&_code]:rounded [&_code]:px-1.5 [&_code]:py-0.5 [&_code]:text-sm">
                  <%= Phoenix.HTML.raw(@description_html) %>
                </div>
              </div>
            </div>

            <%!-- Divider --%>
            <div :if={@tags != [] or @credentials != []} class="border-t border-black/[0.07] dark:border-white/[0.07] mb-16"></div>

            <%!-- Section 02 — Technologies --%>
            <div :if={@tags != []} class="mb-16">
              <div class="flex items-center gap-4 mb-8">
                <span class="text-5xl font-black text-base-content/[0.06] dark:text-base-content/[0.05] leading-none select-none font-mono">02</span>
                <div>
                  <p class="text-[10px] font-black text-primary/70 uppercase tracking-[0.18em] mb-0.5">Tech</p>
                  <h2 class="text-xl font-black">{gettext("Technologies Used")}</h2>
                </div>
              </div>
              <div class="pl-0 sm:pl-[72px]">
                <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
                  <div
                    :for={{tag, i} <- Enum.with_index(@tags)}
                    class="flex items-center gap-3 px-4 py-3 rounded-xl border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 hover:border-primary/30 hover:bg-primary/4 dark:hover:bg-primary/8 transition-all cursor-default group"
                  >
                    <div class={["w-7 h-7 rounded-lg flex items-center justify-center shrink-0 text-[10px] font-black", tag_color(i)]}>
                      {tag |> String.slice(0, 2) |> String.upcase()}
                    </div>
                    <span class="text-sm font-semibold text-base-content/65 group-hover:text-base-content/90 transition-colors truncate">
                      {tag}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <%!-- Divider --%>
            <div :if={@credentials != []} class="border-t border-black/[0.07] dark:border-white/[0.07] mb-16"></div>

            <%!-- Section 03 — Demo Credentials --%>
            <div :if={@credentials != []}>
              <div class="flex items-center gap-4 mb-8">
                <span class="text-5xl font-black text-base-content/[0.06] dark:text-base-content/[0.05] leading-none select-none font-mono">
                  {if @tags != [], do: "03", else: "02"}
                </span>
                <div>
                  <p class="text-[10px] font-black text-amber-500/80 uppercase tracking-[0.18em] mb-0.5">Access</p>
                  <h2 class="text-xl font-black">{gettext("Demo Credentials")}</h2>
                </div>
              </div>
              <div class="pl-0 sm:pl-[72px] space-y-4">
                <div
                  :for={{cred, idx} <- Enum.with_index(@credentials)}
                  class="rounded-2xl border border-black/[0.08] dark:border-white/[0.08] bg-white dark:bg-base-200 overflow-hidden"
                >
                  <div :if={cred["role"] not in [nil, ""]} class="px-5 py-3 border-b border-black/[0.06] dark:border-white/[0.06] bg-amber-50 dark:bg-amber-500/8 flex items-center gap-2">
                    <span class="w-1.5 h-1.5 rounded-full bg-amber-500 shrink-0"></span>
                    <span class="text-xs font-black uppercase tracking-widest text-amber-700 dark:text-amber-400">{cred["role"]}</span>
                  </div>
                  <div class="p-5 grid sm:grid-cols-2 gap-4">
                    <div :if={cred["username"] not in [nil, ""]} class="flex items-center justify-between gap-3">
                      <div class="min-w-0">
                        <p class="text-[10px] font-black text-base-content/30 uppercase tracking-widest mb-1.5">{gettext("Username")}</p>
                        <p class="font-mono font-bold text-sm text-base-content truncate">{cred["username"]}</p>
                      </div>
                      <button
                        id={"copy-#{idx}-username"}
                        phx-hook="CopyText"
                        data-copy={cred["username"]}
                        class="shrink-0 w-8 h-8 rounded-lg border border-black/[0.08] dark:border-white/[0.08] flex items-center justify-center hover:border-amber-400/60 hover:bg-amber-50 dark:hover:bg-amber-500/10 transition-all"
                      >
                        <span class="copy-normal"><.icon name="hero-clipboard-document" class="size-4 text-base-content/30" /></span>
                        <span class="copy-success hidden"><.icon name="hero-check" class="size-4 text-amber-500" /></span>
                      </button>
                    </div>
                    <div :if={cred["password"] not in [nil, ""]} class="flex items-center justify-between gap-3">
                      <div class="min-w-0">
                        <p class="text-[10px] font-black text-base-content/30 uppercase tracking-widest mb-1.5">{gettext("Password")}</p>
                        <p class="font-mono font-bold text-sm text-base-content truncate">{cred["password"]}</p>
                      </div>
                      <button
                        id={"copy-#{idx}-password"}
                        phx-hook="CopyText"
                        data-copy={cred["password"]}
                        class="shrink-0 w-8 h-8 rounded-lg border border-black/[0.08] dark:border-white/[0.08] flex items-center justify-center hover:border-amber-400/60 hover:bg-amber-50 dark:hover:bg-amber-500/10 transition-all"
                      >
                        <span class="copy-normal"><.icon name="hero-clipboard-document" class="size-4 text-base-content/30" /></span>
                        <span class="copy-success hidden"><.icon name="hero-check" class="size-4 text-amber-500" /></span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <%!-- ── RIGHT: Sticky sidebar ── --%>
          <div class="space-y-4 lg:sticky lg:top-24 lg:self-start">

            <%!-- Status card --%>
            <div class="rounded-2xl border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 overflow-hidden">
              <div class="px-5 py-4 border-b border-black/[0.06] dark:border-white/[0.06]">
                <p class="text-[10px] font-black text-base-content/35 uppercase tracking-widest">{gettext("Project Info")}</p>
              </div>
              <div class="p-5 space-y-4">
                <div class="flex items-center justify-between">
                  <span class="text-xs font-semibold text-base-content/40">{gettext("Category")}</span>
                  <span class="text-xs font-bold capitalize text-base-content/75">{@project.client_type}</span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="text-xs font-semibold text-base-content/40">{gettext("Status")}</span>
                  <span :if={@project.live_url} class="flex items-center gap-1.5 text-xs font-bold text-emerald-600 dark:text-emerald-400">
                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                    {gettext("Live")}
                  </span>
                  <span :if={!@project.live_url} class="text-xs font-bold text-base-content/40">{gettext("Internal")}</span>
                </div>
                <div :if={@tags != []} class="pt-2 border-t border-black/[0.06] dark:border-white/[0.06]">
                  <span class="text-xs font-semibold text-base-content/40 block mb-3">{gettext("Stack")}</span>
                  <div class="flex flex-wrap gap-1.5">
                    <span
                      :for={tag <- Enum.take(@tags, 8)}
                      class="text-[10px] font-semibold px-2.5 py-1 rounded-full border border-black/[0.09] dark:border-white/[0.09] text-base-content/50"
                    >
                      {tag}
                    </span>
                    <span :if={length(@tags) > 8} class="text-[10px] font-semibold px-2.5 py-1 rounded-full border border-black/[0.09] dark:border-white/[0.09] text-base-content/30">
                      +{length(@tags) - 8}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <%!-- Live URL CTA --%>
            <a
              :if={@project.live_url}
              href={@project.live_url}
              target="_blank"
              rel="noopener"
              class="flex items-center justify-center gap-2 w-full py-3.5 rounded-2xl font-bold text-sm bg-gradient-to-r from-primary to-secondary text-white shadow-lg shadow-primary/20 hover:opacity-90 hover:scale-[1.01] transition-all"
            >
              <.icon name="hero-globe-alt" class="size-4" />
              {gettext("View Live Project")}
              <.icon name="hero-arrow-top-right-on-square" class="size-3.5" />
            </a>

            <%!-- Build similar --%>
            <a
              href="/#booking"
              class="flex items-center justify-center gap-2 w-full py-3.5 rounded-2xl font-bold text-sm border border-black/[0.09] dark:border-white/[0.09] hover:border-primary/40 hover:text-primary bg-white dark:bg-base-200 transition-all"
            >
              <.icon name="hero-wrench-screwdriver" class="size-4" />
              {gettext("Build Something Similar")}
            </a>

            <%!-- CTA mini card --%>
            <div class="rounded-2xl bg-gradient-to-br from-primary/8 to-secondary/5 dark:from-primary/12 dark:to-secondary/8 border border-primary/15 dark:border-primary/20 p-5">
              <div class="flex items-start gap-3 mb-4">
                <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shrink-0 shadow-sm shadow-primary/20">
                  <.icon name="hero-light-bulb" class="size-4 text-white" />
                </div>
                <div>
                  <p class="font-black text-sm mb-1">{gettext("Like what you see?")}</p>
                  <p class="text-xs text-base-content/50 leading-relaxed">
                    {gettext("We build custom solutions like this for businesses worldwide.")}
                  </p>
                </div>
              </div>
              <a href="/#booking" class="flex items-center gap-1.5 text-xs font-bold text-primary hover:gap-3 transition-all">
                {gettext("Start your project")} <.icon name="hero-arrow-right" class="size-3.5" />
              </a>
            </div>
          </div>
        </div>
      </div>

      <%!-- ═══ MORE PROJECTS ═══ --%>
      <section :if={@others != []} class="border-t border-black/[0.07] dark:border-white/[0.07] px-4 sm:px-6 lg:px-8 py-16">
        <div class="max-w-6xl mx-auto">
          <div class="flex items-center justify-between mb-10">
            <div>
              <h2 class="text-2xl font-black">
                {gettext("More")} <span class="text-primary">{gettext("Projects")}</span>
              </h2>
              <p class="text-base-content/40 text-sm mt-0.5">{gettext("Other work you might find interesting")}</p>
            </div>
            <.link navigate={~p"/#projects"} class="text-sm font-bold text-primary inline-flex items-center gap-1.5 hover:gap-2.5 transition-all">
              {gettext("View All")} <.icon name="hero-arrow-right" class="size-4" />
            </.link>
          </div>

          <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
            <.link
              :for={project <- @others}
              navigate={~p"/projects/#{project.id}"}
              class="group flex flex-col rounded-2xl overflow-hidden border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 hover:border-primary/25 dark:hover:border-primary/25 hover:shadow-lg hover:shadow-primary/6 hover:-translate-y-1 transition-all duration-300"
            >
              <div class="relative aspect-video overflow-hidden shrink-0 bg-base-200 dark:bg-base-300">
                <img
                  :if={project.cover_image}
                  src={project.cover_image}
                  alt={project.name}
                  class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <div
                  :if={!project.cover_image}
                  class="w-full h-full bg-gradient-to-br from-primary/12 to-secondary/10 flex items-center justify-center"
                >
                  <.icon name="hero-briefcase" class="size-10 text-primary/20" />
                </div>
                <span :if={project.live_url} class="absolute top-3 right-3 flex items-center gap-1 text-[10px] font-bold px-2.5 py-1 rounded-full bg-emerald-500 text-white">
                  <span class="w-1 h-1 rounded-full bg-white animate-pulse"></span>
                  {gettext("Live")}
                </span>
              </div>
              <div class="p-5 flex flex-col flex-1">
                <span class="text-[10px] font-black text-base-content/28 uppercase tracking-widest mb-1.5 capitalize">{project.client_type}</span>
                <h3 class="font-black text-base mb-2 group-hover:text-primary transition-colors">{project.name}</h3>
                <p class="text-sm text-base-content/50 line-clamp-2 leading-relaxed flex-1 mb-4">
                  {InnosoWeb.Markdown.plain_text(project.description)}
                </p>
                <div class="flex items-center justify-between pt-3 border-t border-black/[0.06] dark:border-white/[0.06]">
                  <span class="text-xs font-bold text-primary inline-flex items-center gap-1.5 group-hover:gap-2.5 transition-all">
                    {gettext("View Project")} <.icon name="hero-arrow-right" class="size-3.5" />
                  </span>
                  <.icon name="hero-arrow-up-right" class="size-4 text-base-content/20 group-hover:text-primary group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-all" />
                </div>
              </div>
            </.link>
          </div>
        </div>
      </section>

      <%!-- ═══ CTA BANNER ═══ --%>
      <section class="px-4 sm:px-6 lg:px-8 py-16">
        <div class="max-w-6xl mx-auto">
          <div class="relative rounded-3xl bg-gray-950 overflow-hidden px-8 py-16 sm:px-16 text-center">
            <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,rgba(139,92,246,0.25),transparent_55%)] pointer-events-none"></div>
            <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_bottom_left,rgba(236,72,153,0.15),transparent_55%)] pointer-events-none"></div>
            <div class="absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.03)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.03)_1px,transparent_1px)] bg-[size:48px_48px] pointer-events-none"></div>
            <div class="relative">
              <span class="inline-flex items-center gap-2 text-[11px] font-black uppercase tracking-[0.15em] px-4 py-2 rounded-full bg-white/8 border border-white/15 text-white/60 mb-6">
                <span class="w-1.5 h-1.5 rounded-full bg-primary animate-pulse"></span>
                {gettext("Let's Work Together")}
              </span>
              <h2 class="text-3xl sm:text-4xl lg:text-5xl font-black text-white mb-4 tracking-tight leading-tight">
                {gettext("Ready to build")}
                <span class="text-primary"> {gettext("something like this?")}</span>
              </h2>
              <p class="text-white/45 mb-10 max-w-lg mx-auto leading-relaxed">
                {gettext("Tell us about your idea and we'll bring it to life — same care, same quality.")}
              </p>
              <a href="/#booking" class="btn btn-lg rounded-2xl font-black bg-gradient-to-r from-primary to-secondary text-white border-0 shadow-2xl shadow-primary/30 gap-2 px-10 hover:opacity-90 hover:scale-[1.02] transition-all">
                {gettext("Book a Free Call")}
                <.icon name="hero-arrow-right" class="size-5" />
              </a>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══ FOOTER ═══ --%>
      <footer class="px-4 sm:px-6 py-8 border-t border-black/[0.06] dark:border-white/[0.06]">
        <div class="max-w-6xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-base-content/35">
          <.link navigate={~p"/"} class="flex items-center gap-2 hover:text-base-content transition-colors font-medium">
            <div class="w-6 h-6 rounded-lg bg-gradient-to-br from-primary to-secondary flex items-center justify-center">
              <span class="text-white font-black text-[9px] select-none">IN</span>
            </div>
            Innoso
          </.link>
          <div class="flex items-center gap-6">
            <.link navigate={~p"/"} class="hover:text-base-content transition-colors">{gettext("Home")}</.link>
            <a href="/#projects" class="hover:text-base-content transition-colors">{gettext("Portfolio")}</a>
            <a href="/#booking" class="hover:text-base-content transition-colors">{gettext("Contact")}</a>
          </div>
          <span>© {DateTime.utc_now().year} Innoso</span>
        </div>
      </footer>
    </div>
    """
  end

  @tag_colors [
    "bg-blue-500/15 border border-blue-500/20 text-blue-500 dark:text-blue-400",
    "bg-violet-500/15 border border-violet-500/20 text-violet-500 dark:text-violet-400",
    "bg-emerald-500/15 border border-emerald-500/20 text-emerald-600 dark:text-emerald-400",
    "bg-amber-500/15 border border-amber-500/20 text-amber-600 dark:text-amber-400",
    "bg-rose-500/15 border border-rose-500/20 text-rose-500 dark:text-rose-400",
    "bg-cyan-500/15 border border-cyan-500/20 text-cyan-600 dark:text-cyan-400",
    "bg-orange-500/15 border border-orange-500/20 text-orange-500 dark:text-orange-400",
    "bg-pink-500/15 border border-pink-500/20 text-pink-500 dark:text-pink-400",
    "bg-indigo-500/15 border border-indigo-500/20 text-indigo-500 dark:text-indigo-400",
    "bg-teal-500/15 border border-teal-500/20 text-teal-600 dark:text-teal-400"
  ]

  defp tag_color(index) do
    Enum.at(@tag_colors, rem(index, length(@tag_colors)))
  end
end
