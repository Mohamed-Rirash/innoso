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
    <div class="min-h-screen bg-base-100 antialiased">

      <%!-- Navbar --%>
      <nav class="sticky top-0 z-50 bg-white/80 dark:bg-base-100/80 backdrop-blur-xl border-b border-black/[0.07] dark:border-white/[0.07] px-4 sm:px-6 lg:px-8">
        <div class="max-w-5xl mx-auto h-14 flex items-center justify-between">
          <.link navigate={~p"/#team"} class="flex items-center gap-2 text-sm font-semibold text-base-content/50 hover:text-base-content transition-colors group">
            <.icon name="hero-arrow-left" class="size-4 group-hover:-translate-x-0.5 transition-transform" />
            {gettext("Back to team")}
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

      <%!-- ═══ HERO ═══ --%>
      <section class="px-4 sm:px-6 py-20 text-center max-w-3xl mx-auto">
        <%!-- Profile photo --%>
        <div class="relative inline-block mb-8">
          <div class="w-36 h-36 sm:w-44 sm:h-44 rounded-full overflow-hidden ring-4 ring-white dark:ring-base-200 shadow-2xl mx-auto">
            <img
              :if={@member.photo}
              src={@member.photo}
              alt={@member.name}
              class="w-full h-full object-cover object-top"
            />
            <div
              :if={!@member.photo}
              class="w-full h-full bg-gradient-to-br from-primary/25 via-violet-500/15 to-secondary/20 flex items-center justify-center"
            >
              <span class="text-5xl font-black text-primary/40 select-none">
                {@member.name |> String.split(" ") |> Enum.map(&String.first/1) |> Enum.take(2) |> Enum.join()}
              </span>
            </div>
          </div>
          <span class="absolute bottom-2 right-2 w-5 h-5 rounded-full bg-emerald-500 border-2 border-white dark:border-base-100 shadow-md"></span>
        </div>

        <%!-- Identity --%>
        <p class="text-base-content/45 text-lg font-medium mb-2">{gettext("Hi, I'm")}</p>
        <h1 class="text-5xl sm:text-6xl font-black tracking-tight mb-3">{@member.name}</h1>
        <p class="text-xl font-bold text-primary mb-10">{@member.role}</p>

        <%!-- CTA buttons --%>
        <div class="flex flex-wrap gap-3 justify-center">
          <a href="/#booking" class="btn btn-lg rounded-2xl font-bold gap-2 bg-gradient-to-r from-primary to-secondary text-white border-0 shadow-lg shadow-primary/25 hover:opacity-90 hover:scale-[1.02] transition-all px-8">
            {gettext("Book a Call")}
            <.icon name="hero-arrow-right" class="size-5" />
          </a>
          <.link navigate={~p"/#projects"} class="btn btn-lg rounded-2xl font-bold border border-black/[0.10] dark:border-white/[0.12] bg-transparent hover:bg-base-200 text-base-content transition-all px-8">
            {gettext("View Our Work")}
          </.link>
        </div>
      </section>

      <%!-- ═══ ABOUT ═══ --%>
      <section :if={@member.bio} class="px-4 sm:px-6 py-12 max-w-3xl mx-auto">
        <div class="border-t border-black/[0.07] dark:border-white/[0.07] pt-12">
          <h2 class="text-2xl font-black mb-6">{gettext("About Me")}</h2>
          <p class="text-lg text-base-content/60 leading-relaxed">{@member.bio}</p>
        </div>
      </section>

      <%!-- ═══ SKILLS ═══ --%>
      <section :if={@skills != []} class="px-4 sm:px-6 py-12 max-w-3xl mx-auto">
        <div class="border-t border-black/[0.07] dark:border-white/[0.07] pt-12">
          <h2 class="text-2xl font-black mb-8">{gettext("Skills & Technologies")}</h2>
          <div class="flex flex-wrap gap-3">
            <span
              :for={skill <- @skills}
              class="text-sm font-semibold px-4 py-2 rounded-full border border-black/[0.10] dark:border-white/[0.10] text-base-content/65 hover:border-primary/40 hover:text-primary transition-colors cursor-default"
            >
              {skill}
            </span>
          </div>
        </div>
      </section>

      <%!-- ═══ GET IN TOUCH ═══ --%>
      <section class="px-4 sm:px-6 py-16 max-w-3xl mx-auto">
        <div class="border-t border-black/[0.07] dark:border-white/[0.07] pt-12">
          <div class="rounded-2xl bg-white dark:bg-base-200 border border-black/[0.08] dark:border-white/[0.07] p-8 sm:p-12 text-center">
            <h2 class="text-2xl sm:text-3xl font-black mb-3">
              {gettext("Want to work with")} {@member.name |> String.split(" ") |> List.first()}?
            </h2>
            <p class="text-base-content/50 mb-8 leading-relaxed text-lg">
              {gettext("Book a free call and let's talk about what you're building.")}
            </p>
            <div class="flex flex-wrap gap-3 justify-center">
              <a
                href="/#booking"
                class="btn btn-lg rounded-2xl font-bold gap-2 bg-gradient-to-r from-primary to-secondary text-white border-0 shadow-lg shadow-primary/25 hover:opacity-90 transition-all px-8"
              >
                {gettext("Book a Free Call")}
                <.icon name="hero-calendar-days" class="size-5" />
              </a>
              <a
                href="mailto:codesavvylabs@gmail.com"
                class="btn btn-lg rounded-2xl font-bold border border-black/[0.10] dark:border-white/[0.12] bg-transparent hover:bg-base-200 text-base-content transition-all px-8 gap-2"
              >
                <.icon name="hero-envelope" class="size-5" />
                {gettext("Send an Email")}
              </a>
            </div>
          </div>
        </div>
      </section>

      <%!-- Footer --%>
      <footer class="px-4 sm:px-6 py-8 border-t border-black/[0.06] dark:border-white/[0.06] max-w-3xl mx-auto">
        <div class="flex items-center justify-between text-sm text-base-content/35">
          <.link navigate={~p"/"} class="flex items-center gap-2 hover:text-base-content transition-colors font-medium">
            <div class="w-6 h-6 rounded-lg bg-gradient-to-br from-primary to-secondary flex items-center justify-center">
              <span class="text-white font-black text-[9px] select-none">IN</span>
            </div>
            Innoso
          </.link>
          <span>© {DateTime.utc_now().year} Innoso</span>
        </div>
      </footer>
    </div>
    """
  end
end
