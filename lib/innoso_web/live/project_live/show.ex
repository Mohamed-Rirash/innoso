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
        <div class="max-w-5xl mx-auto h-14 flex items-center justify-between">
          <.link
            navigate={~p"/"}
            class="flex items-center gap-2 text-sm font-semibold text-base-content/50 hover:text-base-content transition-colors group"
          >
            <.icon name="hero-arrow-left" class="size-4 group-hover:-translate-x-0.5 transition-transform" />
            <span>{gettext("Back")}</span>
          </.link>

          <.link navigate={~p"/"} class="flex items-center gap-2 group">
            <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-sm shadow-primary/20 group-hover:scale-105 transition-transform">
              <span class="text-white font-black text-xs select-none">IN</span>
            </div>
            <span class="font-black text-base tracking-tight">Innoso</span>
          </.link>

          <a
            href="/#booking"
            class="btn btn-sm rounded-xl font-bold px-4 bg-gradient-to-r from-primary to-secondary text-white border-0 shadow-md shadow-primary/20 hover:opacity-90 transition-all text-xs"
          >
            {gettext("Book a Call")}
          </a>
        </div>
      </nav>

      <%!-- ═══ HERO IMAGE ═══ --%>
      <div class="w-full overflow-hidden bg-base-200 aspect-[16/6] sm:aspect-[16/5] max-h-[520px]">
        <img
          :if={@project.cover_image}
          src={@project.cover_image}
          alt={@project.name}
          class="w-full h-full object-cover"
        />
        <div
          :if={!@project.cover_image}
          class="w-full h-full bg-gradient-to-br from-primary/20 via-violet-600/15 to-secondary/20 flex items-center justify-center"
        >
          <.icon name="hero-briefcase" class="size-20 text-primary/20" />
        </div>
      </div>

      <%!-- ═══ PROJECT HEADER ═══ --%>
      <div class="border-b border-black/[0.07] dark:border-white/[0.07]">
        <div class="max-w-5xl mx-auto px-4 sm:px-6 py-8">
          <div class="flex flex-wrap items-center gap-2 mb-4">
            <span class="text-xs font-bold uppercase tracking-widest text-base-content/40 capitalize">
              {@project.client_type}
            </span>
            <span class="text-base-content/20">·</span>
            <span :if={@project.live_url} class="flex items-center gap-1.5 text-xs font-bold text-emerald-600 dark:text-emerald-400">
              <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
              {gettext("Live")}
            </span>
            <span :if={@credentials != []} class="flex items-center gap-1.5 text-xs font-bold text-amber-600 dark:text-amber-400">
              <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
              {gettext("Demo Available")}
            </span>
          </div>
          <h1 class="text-3xl sm:text-4xl lg:text-5xl font-black tracking-tight leading-tight">
            {@project.name}
          </h1>
        </div>
      </div>

      <%!-- ═══ MAIN CONTENT ═══ --%>
      <div class="max-w-5xl mx-auto px-4 sm:px-6 py-12">
        <div class="grid lg:grid-cols-3 gap-10 lg:gap-16">

          <%!-- Left: Description + Tech + Credentials --%>
          <div class="lg:col-span-2 space-y-12">

            <%!-- About --%>
            <div>
              <h2 class="text-xs font-black text-base-content/35 uppercase tracking-widest mb-5 flex items-center gap-2">
                <span class="h-px w-6 bg-primary inline-block"></span>
                {gettext("About This Project")}
              </h2>
              <div class="text-base text-base-content/65 leading-[1.8] md-content space-y-4">
                <%= Phoenix.HTML.raw(@description_html) %>
              </div>
            </div>

            <%!-- Technologies --%>
            <div :if={@tags != []}>
              <h2 class="text-xs font-black text-base-content/35 uppercase tracking-widest mb-5 flex items-center gap-2">
                <span class="h-px w-6 bg-primary inline-block"></span>
                {gettext("Technologies Used")}
              </h2>
              <div class="flex flex-wrap gap-2">
                <span
                  :for={tag <- @tags}
                  class="text-sm font-semibold px-4 py-2 rounded-full border border-black/[0.10] dark:border-white/[0.10] text-base-content/60 hover:border-primary/40 hover:text-primary transition-colors cursor-default"
                >
                  {tag}
                </span>
              </div>
            </div>

            <%!-- Demo Credentials --%>
            <div :if={@credentials != []}>
              <h2 class="text-xs font-black text-base-content/35 uppercase tracking-widest mb-5 flex items-center gap-2">
                <span class="h-px w-6 bg-amber-500 inline-block"></span>
                {gettext("Demo Credentials")}
              </h2>
              <div class="space-y-4">
                <div
                  :for={{cred, idx} <- Enum.with_index(@credentials)}
                  class="rounded-xl border border-black/[0.08] dark:border-white/[0.08] bg-white dark:bg-base-200 p-5"
                >
                  <span
                    :if={cred["role"] not in [nil, ""]}
                    class="inline-flex items-center gap-1.5 text-[11px] font-black uppercase tracking-widest text-amber-600 dark:text-amber-400 mb-4 block"
                  >
                    {cred["role"]}
                  </span>
                  <div class="grid sm:grid-cols-2 gap-4">
                    <div :if={cred["username"] not in [nil, ""]} class="flex items-center justify-between gap-3">
                      <div class="min-w-0">
                        <p class="text-[10px] font-black text-base-content/35 uppercase tracking-widest mb-1">{gettext("Username")}</p>
                        <p class="font-mono font-bold text-sm text-base-content truncate">{cred["username"]}</p>
                      </div>
                      <button
                        id={"copy-#{idx}-username"}
                        phx-hook="CopyText"
                        data-copy={cred["username"]}
                        class="shrink-0 w-8 h-8 rounded-lg border border-black/[0.08] dark:border-white/[0.08] flex items-center justify-center hover:border-amber-400 hover:bg-amber-50 dark:hover:bg-amber-500/10 transition-all"
                      >
                        <span class="copy-normal"><.icon name="hero-clipboard-document" class="size-4 text-base-content/35" /></span>
                        <span class="copy-success hidden"><.icon name="hero-check" class="size-4 text-amber-500" /></span>
                      </button>
                    </div>
                    <div :if={cred["password"] not in [nil, ""]} class="flex items-center justify-between gap-3">
                      <div class="min-w-0">
                        <p class="text-[10px] font-black text-base-content/35 uppercase tracking-widest mb-1">{gettext("Password")}</p>
                        <p class="font-mono font-bold text-sm text-base-content truncate">{cred["password"]}</p>
                      </div>
                      <button
                        id={"copy-#{idx}-password"}
                        phx-hook="CopyText"
                        data-copy={cred["password"]}
                        class="shrink-0 w-8 h-8 rounded-lg border border-black/[0.08] dark:border-white/[0.08] flex items-center justify-center hover:border-amber-400 hover:bg-amber-50 dark:hover:bg-amber-500/10 transition-all"
                      >
                        <span class="copy-normal"><.icon name="hero-clipboard-document" class="size-4 text-base-content/35" /></span>
                        <span class="copy-success hidden"><.icon name="hero-check" class="size-4 text-amber-500" /></span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <%!-- Right: Sticky sidebar --%>
          <div class="space-y-5 lg:sticky lg:top-24 lg:self-start">

            <%!-- Project meta --%>
            <div class="rounded-2xl border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 overflow-hidden">
              <div class="px-5 py-4 border-b border-black/[0.06] dark:border-white/[0.06]">
                <p class="text-xs font-black text-base-content/40 uppercase tracking-widest">{gettext("Project Details")}</p>
              </div>
              <div class="divide-y divide-black/[0.05] dark:divide-white/[0.05]">
                <div class="px-5 py-4">
                  <p class="text-[10px] font-black text-base-content/35 uppercase tracking-widest mb-1">{gettext("Category")}</p>
                  <p class="font-semibold text-sm capitalize text-base-content/75">{@project.client_type}</p>
                </div>
                <div :if={@tags != []} class="px-5 py-4">
                  <p class="text-[10px] font-black text-base-content/35 uppercase tracking-widest mb-3">{gettext("Stack")}</p>
                  <div class="flex flex-wrap gap-1.5">
                    <span
                      :for={tag <- Enum.take(@tags, 6)}
                      class="text-[11px] font-semibold px-2.5 py-1 rounded-full border border-black/[0.09] dark:border-white/[0.09] text-base-content/55"
                    >
                      {tag}
                    </span>
                    <span :if={length(@tags) > 6} class="text-[11px] font-semibold px-2.5 py-1 rounded-full border border-black/[0.09] dark:border-white/[0.09] text-base-content/35">
                      +{length(@tags) - 6}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <%!-- Live URL --%>
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
              class="flex items-center justify-center gap-2 w-full py-3.5 rounded-2xl font-bold text-sm border border-black/[0.09] dark:border-white/[0.09] hover:border-primary/40 hover:text-primary transition-all"
            >
              <.icon name="hero-calendar-days" class="size-4" />
              {gettext("Build Something Similar")}
            </a>

            <%!-- Tip --%>
            <div class="rounded-2xl bg-primary/5 dark:bg-primary/8 border border-primary/15 dark:border-primary/20 p-5">
              <p class="font-black text-sm mb-1.5">{gettext("Like what you see?")}</p>
              <p class="text-xs text-base-content/50 leading-relaxed mb-4">
                {gettext("We can build something similar — or even better — for your business.")}
              </p>
              <a href="/#booking" class="text-xs font-bold text-primary inline-flex items-center gap-1.5 hover:gap-2.5 transition-all">
                {gettext("Book a free call")}
                <.icon name="hero-arrow-right" class="size-3.5" />
              </a>
            </div>
          </div>
        </div>
      </div>

      <%!-- ═══ OTHER PROJECTS ═══ --%>
      <section :if={@others != []} class="border-t border-black/[0.07] dark:border-white/[0.07] px-4 sm:px-6 lg:px-8 py-16">
        <div class="max-w-5xl mx-auto">
          <div class="flex items-center justify-between mb-10">
            <h2 class="text-2xl font-black">{gettext("More Projects")}</h2>
            <.link navigate={~p"/"} class="text-sm font-bold text-primary inline-flex items-center gap-1.5 hover:gap-2.5 transition-all">
              {gettext("View All")} <.icon name="hero-arrow-right" class="size-4" />
            </.link>
          </div>

          <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <.link
              :for={project <- @others}
              navigate={~p"/projects/#{project.id}"}
              class="group flex flex-col rounded-2xl overflow-hidden border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 hover:border-primary/25 dark:hover:border-primary/25 hover:shadow-lg hover:shadow-primary/5 hover:-translate-y-1 transition-all duration-300"
            >
              <div class="relative aspect-video overflow-hidden shrink-0">
                <img
                  :if={project.cover_image}
                  src={project.cover_image}
                  alt={project.name}
                  class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <div
                  :if={!project.cover_image}
                  class="w-full h-full bg-gradient-to-br from-primary/10 to-secondary/10 flex items-center justify-center"
                >
                  <.icon name="hero-briefcase" class="size-10 text-primary/20" />
                </div>
                <div :if={project.live_url} class="absolute top-3 right-3 flex items-center gap-1.5 text-[10px] font-bold px-2.5 py-1 rounded-full bg-emerald-500 text-white">
                  <span class="w-1 h-1 rounded-full bg-white animate-pulse"></span>
                  {gettext("Live")}
                </div>
              </div>
              <div class="p-5 flex flex-col flex-1">
                <span class="text-[10px] font-black text-base-content/30 uppercase tracking-widest mb-2 capitalize">{project.client_type}</span>
                <h3 class="font-black text-base mb-2 group-hover:text-primary transition-colors">{project.name}</h3>
                <p class="text-sm text-base-content/50 line-clamp-2 leading-relaxed flex-1 mb-4">
                  {InnosoWeb.Markdown.plain_text(project.description)}
                </p>
                <div class="flex items-center justify-between pt-4 border-t border-black/[0.06] dark:border-white/[0.06]">
                  <span class="text-xs font-bold text-primary inline-flex items-center gap-1.5 group-hover:gap-2.5 transition-all">
                    {gettext("View Details")} <.icon name="hero-arrow-right" class="size-3.5" />
                  </span>
                  <.icon name="hero-arrow-up-right" class="size-4 text-base-content/20 group-hover:text-primary transition-colors" />
                </div>
              </div>
            </.link>
          </div>
        </div>
      </section>

      <%!-- ═══ CTA ═══ --%>
      <section class="px-4 sm:px-6 lg:px-8 py-16">
        <div class="max-w-5xl mx-auto">
          <div class="rounded-2xl bg-gradient-to-br from-primary via-violet-600 to-secondary p-px shadow-xl shadow-primary/20">
            <div class="rounded-[calc(1rem-1px)] bg-gradient-to-br from-primary/90 via-violet-600/90 to-secondary/90 px-8 py-14 sm:px-14 text-center overflow-hidden relative">
              <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,rgba(255,255,255,0.07),transparent_60%)] pointer-events-none"></div>
              <div class="relative">
                <p class="text-white/60 text-sm font-bold uppercase tracking-widest mb-3">{gettext("Let's Work Together")}</p>
                <h2 class="text-3xl sm:text-4xl font-black text-white mb-4 tracking-tight">
                  {gettext("Ready to build something like this?")}
                </h2>
                <p class="text-white/55 mb-8 max-w-md mx-auto leading-relaxed">
                  {gettext("Tell us about your idea and we'll bring it to life with the same care and quality.")}
                </p>
                <a
                  href="/#booking"
                  class="btn btn-lg rounded-2xl font-black bg-white hover:bg-white/95 text-primary border-0 shadow-xl gap-2 px-8 hover:scale-[1.02] transition-all"
                >
                  {gettext("Book a Free Call")}
                  <.icon name="hero-arrow-right" class="size-5" />
                </a>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══ FOOTER ═══ --%>
      <footer class="px-4 sm:px-6 py-8 border-t border-black/[0.06] dark:border-white/[0.06]">
        <div class="max-w-5xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-base-content/35">
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
end
