defmodule InnosoWeb.TeamLive.Show do
  use InnosoWeb, :live_view

  alias Innoso.Team

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    member = Team.get_member!(id)

    skills =
      if member.skills,
        do:
          member.skills
          |> String.split(",")
          |> Enum.map(&String.trim/1)
          |> Enum.reject(&(&1 == "")),
        else: []

    {:ok,
     socket
     |> assign(:member, member)
     |> assign(:skills, skills)
     |> assign(:page_title, member.name <> " — Innoso")
     |> assign(:page_description, member.bio || "Meet #{member.name}, #{member.role} at Innoso.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100 antialiased overflow-x-hidden">
      <div aria-hidden="true" class="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
        <div class="absolute -top-[400px] -left-[200px] w-[800px] h-[800px] rounded-full bg-violet-600/8 dark:bg-violet-500/20 blur-[160px]"></div>
        <div class="absolute top-[20%] -right-[300px] w-[700px] h-[700px] rounded-full bg-indigo-500/6 dark:bg-blue-500/16 blur-[150px]"></div>
      </div>

      <%!-- Navbar --%>
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

      <%!-- Profile hero --%>
      <section class="px-4 sm:px-6 lg:px-8 pt-16 pb-10">
        <div class="max-w-3xl mx-auto">
          <div class="flex flex-col sm:flex-row items-center sm:items-start gap-8">
            <%!-- Avatar --%>
            <div class="relative shrink-0">
              <div class="absolute inset-0 bg-gradient-to-br from-primary/40 to-secondary/30 rounded-3xl blur-2xl scale-110 pointer-events-none"></div>
              <div class="relative w-40 h-40 rounded-3xl overflow-hidden border-2 border-white/20 shadow-2xl">
                <img
                  :if={@member.photo}
                  src={@member.photo}
                  alt={@member.name}
                  class="w-full h-full object-cover object-top"
                />
                <div
                  :if={!@member.photo}
                  class="w-full h-full bg-gradient-to-br from-primary/20 via-violet-500/15 to-secondary/20 flex items-center justify-center"
                >
                  <span class="text-6xl font-black text-primary/40 select-none leading-none">
                    {@member.name |> String.split(" ") |> Enum.map(&String.first/1) |> Enum.take(2) |> Enum.join()}
                  </span>
                </div>
              </div>
            </div>

            <%!-- Info --%>
            <div class="text-center sm:text-left">
              <span class="inline-flex items-center gap-1.5 text-xs font-black text-primary uppercase tracking-widest bg-primary/10 dark:bg-primary/15 border border-primary/20 dark:border-primary/25 px-3 py-1.5 rounded-full mb-4">
                <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
                {gettext("Team Member")}
              </span>
              <h1 class="text-4xl sm:text-5xl font-black tracking-tight mb-2">{@member.name}</h1>
              <p class="text-lg font-bold text-primary/80 mb-5">{@member.role}</p>

              <div :if={@skills != []} class="flex flex-wrap gap-2 justify-center sm:justify-start">
                <span
                  :for={skill <- @skills}
                  class="text-xs font-bold px-3 py-1.5 rounded-full bg-primary/8 dark:bg-primary/12 border border-primary/15 dark:border-primary/20 text-primary"
                >
                  {skill}
                </span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- Bio --%>
      <section :if={@member.bio} class="px-4 sm:px-6 lg:px-8 py-8">
        <div class="max-w-3xl mx-auto">
          <div class="group relative rounded-2xl border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 p-8 overflow-hidden transition-all duration-300 hover:border-primary/30 dark:hover:border-primary/40">
            <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-primary opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            <div class="absolute -bottom-4 left-1/2 -translate-x-1/2 w-1/2 h-12 bg-primary/40 blur-2xl opacity-0 group-hover:opacity-80 transition-all duration-500 pointer-events-none"></div>
            <p class="text-xs font-black text-primary uppercase tracking-widest mb-4 flex items-center gap-2">
              <.icon name="hero-user" class="size-3.5" />
              {gettext("About")}
            </p>
            <p class="text-base-content/65 leading-relaxed text-lg">{@member.bio}</p>
          </div>
        </div>
      </section>

      <%!-- CTA --%>
      <section class="px-4 sm:px-6 lg:px-8 py-16">
        <div class="max-w-3xl mx-auto text-center">
          <p class="text-base-content/50 mb-5 text-lg">
            {gettext("Want to work with")} {@member.name}?
          </p>
          <a
            href="/#booking"
            class="btn btn-lg rounded-2xl font-black gap-2 bg-gradient-to-r from-primary to-secondary text-white border-0 shadow-xl shadow-primary/30 hover:opacity-90 hover:scale-[1.02] transition-all"
          >
            {gettext("Book a Free Call")}
            <.icon name="hero-arrow-right" class="size-5" />
          </a>
        </div>
      </section>
    </div>
    """
  end
end
