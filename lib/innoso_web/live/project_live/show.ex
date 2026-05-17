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
     |> assign(:page_title, project.name <> " — Innoso")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100 antialiased overflow-x-hidden">

      <%!-- Fixed gradient orbs --%>
      <div aria-hidden="true" class="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
        <div class="absolute -top-[400px] -left-[200px] w-[900px] h-[900px] rounded-full bg-violet-600/8 dark:bg-violet-500/20 blur-[160px]"></div>
        <div class="absolute top-[20%] -right-[300px] w-[800px] h-[800px] rounded-full bg-indigo-500/6 dark:bg-blue-500/16 blur-[150px]"></div>
        <div class="absolute bottom-[15%] -left-[100px] w-[700px] h-[700px] rounded-full bg-cyan-400/5 dark:bg-cyan-400/12 blur-[140px]"></div>
        <div class="absolute top-[60%] right-[10%] w-[600px] h-[600px] rounded-full bg-pink-500/4 dark:bg-pink-500/10 blur-[120px]"></div>
      </div>

      <%!-- ═══════════════════ NAVBAR ═══════════════════ --%>
      <nav class="sticky top-0 z-50 bg-white/75 dark:bg-black/35 backdrop-blur-2xl border-b border-black/[0.07] dark:border-white/[0.08] px-4 sm:px-6 lg:px-8">
        <div class="max-w-7xl mx-auto h-16 flex items-center gap-4">
          <.link
            navigate={~p"/"}
            class="flex items-center gap-2 shrink-0 text-sm font-semibold text-base-content/55 hover:text-base-content transition-colors group"
          >
            <div class="w-8 h-8 rounded-xl bg-white/60 dark:bg-white/[0.07] backdrop-blur-sm border border-black/[0.07] dark:border-white/[0.10] flex items-center justify-center group-hover:border-primary/40 transition-colors">
              <.icon name="hero-arrow-left" class="size-4 group-hover:-translate-x-0.5 transition-transform" />
            </div>
            <span class="hidden sm:inline">{gettext("Back")}</span>
          </.link>

          <.link navigate={~p"/"} class="flex items-center gap-2.5 mx-auto group">
            <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-lg shadow-primary/30 group-hover:scale-105 transition-transform duration-200">
              <span class="text-white font-black text-sm select-none tracking-tight">IN</span>
            </div>
            <span class="font-black text-xl tracking-tight">Innoso</span>
          </.link>

          <a
            href="/#booking"
            class="shrink-0 btn btn-sm rounded-xl font-bold px-4 gap-1.5 bg-gradient-to-r from-primary to-secondary text-white border-0 shadow-lg shadow-primary/25 hover:opacity-90 hover:scale-[1.02] transition-all"
          >
            {gettext("Book a Call")}
            <.icon name="hero-arrow-right" class="size-3.5" />
          </a>
        </div>
      </nav>

      <%!-- ═══════════════════ HERO IMAGE ═══════════════════ --%>
      <div class="relative h-[60vh] min-h-80 overflow-hidden">
        <img
          :if={@project.cover_image}
          src={@project.cover_image}
          alt={@project.name}
          class="w-full h-full object-cover"
        />
        <div :if={!@project.cover_image} class="w-full h-full relative overflow-hidden bg-base-200">
          <div class="absolute inset-0 bg-gradient-to-br from-primary/25 via-violet-500/15 to-secondary/25"></div>
          <div class="absolute inset-0 flex items-center justify-center">
            <div class="relative">
              <div class="absolute inset-0 bg-primary/20 rounded-3xl blur-3xl scale-150"></div>
              <div class="relative w-28 h-28 rounded-3xl bg-white/10 dark:bg-white/[0.08] backdrop-blur-xl border border-white/20 flex items-center justify-center shadow-2xl">
                <.icon name="hero-briefcase" class="size-14 text-primary/60 dark:text-white/40" />
              </div>
            </div>
          </div>
          <div class="absolute top-10 left-10 w-40 h-40 rounded-full bg-primary/10 blur-3xl"></div>
          <div class="absolute bottom-10 right-10 w-32 h-32 rounded-full bg-secondary/10 blur-3xl"></div>
        </div>

        <div class="absolute inset-0 bg-gradient-to-t from-base-100 via-base-100/20 to-transparent"></div>

        <div class="absolute bottom-0 left-0 right-0 px-4 sm:px-6 lg:px-8 pb-10">
          <div class="max-w-7xl mx-auto">
            <div class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-black/50 backdrop-blur-xl border border-white/15 text-xs font-black uppercase tracking-widest text-white/90 mb-4 shadow-sm">
              <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
              {@project.client_type}
            </div>
            <h1 class="text-4xl sm:text-5xl lg:text-6xl font-black tracking-tight leading-[1.05] max-w-4xl">
              {@project.name}
            </h1>
          </div>
        </div>
      </div>

      <%!-- ═══════════════════ MAIN CONTENT ═══════════════════ --%>
      <section class="px-4 sm:px-6 lg:px-8 py-14">
        <div class="max-w-7xl mx-auto grid lg:grid-cols-3 gap-8 lg:gap-12">

          <%!-- Left column (2/3) --%>
          <div class="lg:col-span-2 space-y-5">

            <%!-- Description card — primary glow --%>
            <div class="group relative rounded-2xl border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 p-8 overflow-hidden transition-all duration-300 hover:border-primary/30 dark:hover:border-primary/40">
              <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-primary opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <div class="absolute -bottom-4 left-1/2 -translate-x-1/2 w-1/2 h-12 bg-primary/40 blur-2xl opacity-0 group-hover:opacity-80 transition-all duration-500 pointer-events-none"></div>

              <p class="text-xs font-black text-primary uppercase tracking-widest mb-5 flex items-center gap-2">
                <.icon name="hero-document-text" class="size-3.5" />
                {gettext("About This Project")}
              </p>
              <div class="text-base text-base-content/65 leading-relaxed md-content">
                <%= Phoenix.HTML.raw(@description_html) %>
              </div>
            </div>

            <%!-- Technologies card — secondary glow --%>
            <div :if={@tags != []} class="group relative rounded-2xl border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 p-8 overflow-hidden transition-all duration-300 hover:border-secondary/30 dark:hover:border-secondary/40">
              <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-secondary opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <div class="absolute -bottom-4 left-1/2 -translate-x-1/2 w-1/2 h-12 bg-secondary/40 blur-2xl opacity-0 group-hover:opacity-80 transition-all duration-500 pointer-events-none"></div>

              <p class="text-xs font-black text-primary uppercase tracking-widest mb-5 flex items-center gap-2">
                <.icon name="hero-cpu-chip" class="size-3.5" />
                {gettext("Technologies Used")}
              </p>
              <div class="flex flex-wrap gap-2.5">
                <span
                  :for={tag <- @tags}
                  class="px-4 py-2 rounded-xl text-sm font-bold bg-black/[0.04] dark:bg-white/[0.06] border border-black/[0.07] dark:border-white/[0.10] text-base-content/70 hover:border-primary/40 hover:text-primary transition-all duration-200 cursor-default"
                >
                  {tag}
                </span>
              </div>
            </div>

            <%!-- Demo credentials card — amber glow --%>
            <div :if={@credentials != []} class="group relative rounded-2xl border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 p-8 overflow-hidden transition-all duration-300 hover:border-amber-500/30 dark:hover:border-amber-500/40">
              <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-amber-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <div class="absolute -bottom-4 left-1/2 -translate-x-1/2 w-1/2 h-12 bg-amber-500/40 blur-2xl opacity-0 group-hover:opacity-80 transition-all duration-500 pointer-events-none"></div>

              <p class="text-xs font-black text-primary uppercase tracking-widest mb-5 flex items-center gap-2">
                <.icon name="hero-key" class="size-3.5" />
                {gettext("Demo Credentials")}
              </p>

              <div class="space-y-4">
                <div
                  :for={{cred, idx} <- Enum.with_index(@credentials)}
                  class="rounded-xl border border-black/[0.07] dark:border-white/[0.08] bg-black/[0.02] dark:bg-white/[0.03] p-4"
                >
                  <%!-- Role badge --%>
                  <div
                    :if={cred["role"] not in [nil, ""]}
                    class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-amber-500/10 border border-amber-500/20 text-[11px] font-black text-amber-600 dark:text-amber-400 uppercase tracking-widest mb-4"
                  >
                    <span class="w-1.5 h-1.5 rounded-full bg-amber-500 shrink-0"></span>
                    {cred["role"]}
                  </div>

                  <div class="grid sm:grid-cols-2 gap-3">
                    <%!-- Username --%>
                    <div :if={cred["username"] not in [nil, ""]} class="flex items-start justify-between gap-2">
                      <div class="min-w-0">
                        <p class="text-[10px] font-black text-base-content/40 uppercase tracking-widest mb-1.5">
                          {gettext("Username")}
                        </p>
                        <p class="font-mono font-bold text-sm text-base-content tracking-wide truncate">
                          {cred["username"]}
                        </p>
                      </div>
                      <button
                        id={"copy-#{idx}-username"}
                        phx-hook="CopyText"
                        data-copy={cred["username"]}
                        class="w-7 h-7 rounded-lg bg-black/[0.04] dark:bg-white/[0.06] border border-black/[0.07] dark:border-white/[0.10] flex items-center justify-center hover:bg-amber-500/10 hover:border-amber-500/30 transition-all shrink-0 mt-5"
                      >
                        <span class="copy-normal">
                          <.icon name="hero-clipboard-document" class="size-3.5 text-base-content/40" />
                        </span>
                        <span class="copy-success hidden">
                          <.icon name="hero-check" class="size-3.5 text-amber-500" />
                        </span>
                      </button>
                    </div>

                    <%!-- Password --%>
                    <div :if={cred["password"] not in [nil, ""]} class="flex items-start justify-between gap-2">
                      <div class="min-w-0">
                        <p class="text-[10px] font-black text-base-content/40 uppercase tracking-widest mb-1.5">
                          {gettext("Password")}
                        </p>
                        <p class="font-mono font-bold text-sm text-base-content tracking-wide truncate">
                          {cred["password"]}
                        </p>
                      </div>
                      <button
                        id={"copy-#{idx}-password"}
                        phx-hook="CopyText"
                        data-copy={cred["password"]}
                        class="w-7 h-7 rounded-lg bg-black/[0.04] dark:bg-white/[0.06] border border-black/[0.07] dark:border-white/[0.10] flex items-center justify-center hover:bg-amber-500/10 hover:border-amber-500/30 transition-all shrink-0 mt-5"
                      >
                        <span class="copy-normal">
                          <.icon name="hero-clipboard-document" class="size-3.5 text-base-content/40" />
                        </span>
                        <span class="copy-success hidden">
                          <.icon name="hero-check" class="size-3.5 text-amber-500" />
                        </span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <%!-- Right column (1/3) --%>
          <div class="space-y-4">

            <%!-- Project details card --%>
            <div class="group relative rounded-2xl border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 overflow-hidden transition-all duration-300 hover:border-primary/30 dark:hover:border-primary/40">
              <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-primary opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <div class="absolute -bottom-4 left-1/2 -translate-x-1/2 w-1/2 h-10 bg-primary/30 blur-2xl opacity-0 group-hover:opacity-70 transition-all duration-500 pointer-events-none"></div>

              <div class="px-6 py-4 border-b border-black/[0.06] dark:border-white/[0.07]">
                <h3 class="text-xs font-black text-base-content/50 uppercase tracking-widest">
                  {gettext("Project Details")}
                </h3>
              </div>
              <div class="divide-y divide-black/[0.05] dark:divide-white/[0.06]">
                <div class="px-6 py-4">
                  <p class="text-[10px] font-black text-base-content/40 uppercase tracking-widest mb-1.5">
                    {gettext("Client Type")}
                  </p>
                  <p class="font-bold capitalize text-base-content">{@project.client_type}</p>
                </div>
                <div :if={@tags != []} class="px-6 py-4">
                  <p class="text-[10px] font-black text-base-content/40 uppercase tracking-widest mb-3">
                    {gettext("Stack")}
                  </p>
                  <div class="flex flex-wrap gap-1.5">
                    <span
                      :for={tag <- Enum.take(@tags, 5)}
                      class="text-[11px] font-bold px-2.5 py-1 rounded-lg bg-primary/8 dark:bg-primary/15 border border-primary/15 dark:border-primary/25 text-primary"
                    >
                      {tag}
                    </span>
                    <span :if={length(@tags) > 5} class="text-[11px] font-bold px-2.5 py-1 rounded-lg bg-black/[0.05] dark:bg-white/[0.06] border border-black/[0.07] dark:border-white/[0.08] text-base-content/50">
                      +{length(@tags) - 5}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <%!-- Live URL button --%>
            <a
              :if={@project.live_url}
              href={@project.live_url}
              target="_blank"
              class="flex items-center justify-center gap-2 w-full py-3.5 rounded-2xl font-black text-sm bg-gradient-to-r from-primary to-secondary text-white border-0 shadow-xl shadow-primary/25 hover:opacity-90 hover:scale-[1.01] transition-all"
            >
              <.icon name="hero-globe-alt" class="size-4" />
              {gettext("View Live Project")}
              <.icon name="hero-arrow-top-right-on-square" class="size-3.5" />
            </a>

            <%!-- Build similar — outlined button --%>
            <a
              href="/#booking"
              class="flex items-center justify-center gap-2 w-full py-3.5 rounded-2xl font-bold text-sm border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 hover:border-primary/50 hover:text-primary transition-all duration-200"
            >
              <.icon name="hero-calendar-days" class="size-4" />
              {gettext("Build Something Similar")}
            </a>

            <%!-- Hint card — subtle primary glow --%>
            <div class="group relative rounded-2xl border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 p-5 overflow-hidden transition-all duration-300 hover:border-primary/30 dark:hover:border-primary/40">
              <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-primary opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <div class="absolute -bottom-4 left-1/2 -translate-x-1/2 w-1/2 h-10 bg-primary/30 blur-2xl opacity-0 group-hover:opacity-70 transition-all duration-500 pointer-events-none"></div>

              <div class="relative flex items-start gap-3">
                <div class="w-10 h-10 rounded-xl bg-primary/10 dark:bg-primary/15 flex items-center justify-center shrink-0 mt-0.5">
                  <.icon name="hero-light-bulb" class="size-5 text-primary" />
                </div>
                <div>
                  <p class="font-black text-sm mb-1">{gettext("Like what you see?")}</p>
                  <p class="text-xs text-base-content/50 leading-relaxed">
                    {gettext("We can build something similar — or even better — for your business. Book a free call to get started.")}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ OTHER PROJECTS ═══════════════════ --%>
      <section :if={@others != []} class="px-4 sm:px-6 lg:px-8 py-20">
        <div class="max-w-7xl mx-auto">
          <div class="flex items-end justify-between mb-12">
            <div>
              <span class="inline-block text-xs font-bold text-primary uppercase tracking-widest bg-primary/10 dark:bg-primary/15 border border-primary/20 dark:border-primary/25 px-4 py-1.5 rounded-full mb-4">
                {gettext("Portfolio")}
              </span>
              <h2 class="text-3xl sm:text-4xl font-black tracking-tight">
                {gettext("Other")}
                <span class="bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
                  {gettext("Projects")}
                </span>
              </h2>
            </div>
            <.link
              navigate={~p"/"}
              class="btn btn-ghost btn-sm rounded-xl font-semibold gap-1.5 text-base-content/55 hover:text-base-content"
            >
              {gettext("View All")} <.icon name="hero-arrow-right" class="size-4" />
            </.link>
          </div>

          <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
            <.link
              :for={project <- @others}
              navigate={~p"/projects/#{project.id}"}
              class="group flex flex-col rounded-2xl border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 overflow-hidden transition-all duration-300 hover:-translate-y-2 relative"
            >
              <div class="relative h-48 overflow-hidden shrink-0">
                <img
                  :if={project.cover_image}
                  src={project.cover_image}
                  alt={project.name}
                  class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <div :if={!project.cover_image} class="w-full h-full bg-gradient-to-br from-primary/12 via-primary/4 to-secondary/12 flex items-center justify-center">
                  <.icon name="hero-briefcase" class="size-10 text-primary/30" />
                </div>
                <div class="absolute inset-0 bg-gradient-to-t from-black/50 via-black/10 to-transparent"></div>
                <span class="absolute top-3 left-3 text-[11px] font-black uppercase tracking-wide px-2.5 py-1 rounded-lg bg-black/50 backdrop-blur-sm border border-white/15 text-white/90">
                  {project.client_type}
                </span>
                <div class="absolute top-3 right-3 w-8 h-8 rounded-xl bg-black/50 backdrop-blur-sm border border-white/15 flex items-center justify-center opacity-0 group-hover:opacity-100 translate-y-1 group-hover:translate-y-0 transition-all duration-200">
                  <.icon name="hero-arrow-up-right" class="size-4 text-white" />
                </div>
              </div>

              <div class="p-5 flex flex-col flex-1 relative">
                <%!-- Neon bottom glow --%>
                <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-primary opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                <div class="absolute -bottom-4 left-1/2 -translate-x-1/2 w-1/2 h-10 bg-primary/40 blur-2xl opacity-0 group-hover:opacity-80 transition-all duration-500 pointer-events-none"></div>

                <h3 class="font-black text-base leading-snug mb-2 group-hover:text-primary transition-colors duration-200">
                  {project.name}
                </h3>
                <p class="text-sm text-base-content/52 line-clamp-2 leading-relaxed flex-1">
                  {InnosoWeb.Markdown.plain_text(project.description)}
                </p>
                <div class="flex items-center justify-between mt-4 pt-4 border-t border-black/[0.06] dark:border-white/[0.07]">
                  <span class="text-sm font-bold text-primary flex items-center gap-1.5">
                    {gettext("View Details")}
                    <.icon name="hero-arrow-right" class="size-3.5 group-hover:translate-x-0.5 transition-transform" />
                  </span>
                  <span :if={project.live_url} class="text-xs text-base-content/35 flex items-center gap-1">
                    <.icon name="hero-globe-alt" class="size-3.5" /> {gettext("Live")}
                  </span>
                </div>
              </div>
            </.link>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ CTA BANNER ═══════════════════ --%>
      <section class="px-4 sm:px-6 lg:px-8 py-16">
        <div class="max-w-6xl mx-auto">
          <div class="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary via-violet-600 to-secondary p-px shadow-2xl shadow-primary/25">
            <div class="relative rounded-[calc(1.5rem-1px)] bg-gradient-to-br from-primary/90 via-violet-600/90 to-secondary/90 backdrop-blur-xl px-8 py-16 sm:px-14 text-center overflow-hidden">
              <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full bg-white/[0.06] pointer-events-none"></div>
              <div class="absolute -bottom-24 -left-24 w-80 h-80 rounded-full bg-white/[0.06] pointer-events-none"></div>
              <div class="relative">
                <div class="inline-flex items-center gap-2 bg-white/15 backdrop-blur-sm border border-white/20 text-white/90 rounded-full px-4 py-1.5 text-xs font-bold uppercase tracking-widest mb-5">
                  <span class="w-1.5 h-1.5 bg-white rounded-full animate-pulse"></span>
                  {gettext("Let's Work Together")}
                </div>
                <h2 class="text-3xl sm:text-4xl lg:text-5xl font-black text-white mb-5 tracking-tight leading-tight">
                  {gettext("Ready to Build")}<br />{gettext("Something Like This?")}
                </h2>
                <p class="text-white/65 text-lg mb-10 max-w-xl mx-auto leading-relaxed">
                  {gettext("Tell us about your idea and we'll turn it into reality — with the same care and quality you see here.")}
                </p>
                <a
                  href="/#booking"
                  class="btn btn-lg rounded-2xl font-black bg-white hover:bg-white/95 text-primary border-0 shadow-2xl gap-2 px-8 hover:scale-[1.02] transition-all"
                >
                  {gettext("Book a Free Consultation")}
                  <.icon name="hero-arrow-right" class="size-5" />
                </a>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ FOOTER ═══════════════════ --%>
      <footer class="px-4 sm:px-6 lg:px-8 pt-10 pb-8 border-t border-black/[0.06] dark:border-white/[0.07]">
        <div class="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
          <.link navigate={~p"/"} class="flex items-center gap-2.5 group">
            <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-md shadow-primary/20 group-hover:scale-105 transition-transform">
              <span class="text-white font-black text-xs select-none">IN</span>
            </div>
            <span class="font-black text-lg tracking-tight">Innoso</span>
          </.link>

          <div class="flex items-center gap-6 text-sm text-base-content/40">
            <.link navigate={~p"/"} class="hover:text-base-content transition-colors font-medium">{gettext("Home")}</.link>
            <a href="/#services" class="hover:text-base-content transition-colors font-medium">{gettext("Services")}</a>
            <a href="/#booking" class="hover:text-base-content transition-colors font-medium">{gettext("Contact")}</a>
          </div>

          <span class="text-sm text-base-content/35">
            © {DateTime.utc_now().year} Innoso. {gettext("All rights reserved.")}
          </span>
        </div>
      </footer>
    </div>
    """
  end
end
