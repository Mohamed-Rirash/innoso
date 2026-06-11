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

    {first_name, rest_name} =
      case String.split(member.name, " ", parts: 2) do
        [first] -> {first, ""}
        [first, rest] -> {first, rest}
      end

    {:ok,
     socket
     |> assign(:member, member)
     |> assign(:skills, skills)
     |> assign(:first_name, first_name)
     |> assign(:rest_name, rest_name)
     |> assign(:page_title, member.name <> " — Innoso")
     |> assign(:page_description, member.bio || "Meet #{member.name}, #{member.role} at Innoso.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div data-theme="dark" class="min-h-screen bg-base-100 antialiased text-base-content">

      <%!-- ═══ NAVBAR ═══ --%>
      <nav class="sticky top-0 z-50 bg-base-100/80 backdrop-blur-xl border-b border-white/[0.07] px-4 sm:px-6 lg:px-8">
        <div class="max-w-5xl mx-auto h-14 flex items-center justify-between">
          <.link navigate={~p"/#team"} class="flex items-center gap-2 text-sm font-semibold text-base-content/45 hover:text-base-content transition-colors group">
            <.icon name="hero-arrow-left" class="size-4 group-hover:-translate-x-0.5 transition-transform" />
            {gettext("Our Team")}
          </.link>
          <.link navigate={~p"/"} class="flex items-center gap-2 group">
            <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-lg shadow-primary/30 group-hover:scale-105 transition-transform">
              <span class="text-white font-black text-xs select-none">IN</span>
            </div>
            <span class="font-black text-base tracking-tight">Innoso</span>
          </.link>
          <a href="/#booking" class="btn btn-sm rounded-xl font-bold px-4 bg-gradient-to-r from-primary to-secondary text-white border-0 shadow-lg shadow-primary/25 hover:opacity-90 transition-all text-xs">
            {gettext("Book a Call")}
          </a>
        </div>
      </nav>

      <%!-- ═══ HERO ═══ --%>
      <section class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-16 sm:py-24">
        <div class="grid md:grid-cols-[300px_1fr] lg:grid-cols-[340px_1fr] gap-12 lg:gap-20 items-start">

          <%!-- Photo — left --%>
          <div class="relative mx-auto w-full max-w-[300px] md:max-w-none">
            <%!-- Glow behind photo --%>
            <div class="absolute -inset-6 bg-gradient-to-br from-primary/25 to-secondary/15 rounded-3xl blur-3xl pointer-events-none"></div>
            <%!-- Photo frame --%>
            <div class="relative rounded-2xl overflow-hidden border border-white/[0.10] shadow-2xl aspect-[4/5]">
              <img
                :if={@member.photo}
                src={@member.photo}
                alt={@member.name}
                class="w-full h-full object-cover object-top"
              />
              <div
                :if={!@member.photo}
                class="w-full h-full bg-gradient-to-br from-primary/20 via-violet-900/40 to-secondary/15 flex flex-col items-center justify-center gap-4"
              >
                <span class="text-7xl font-black text-primary/40 select-none leading-none">
                  {@member.name |> String.split(" ") |> Enum.map(&String.first/1) |> Enum.take(2) |> Enum.join()}
                </span>
              </div>
              <%!-- Bottom gradient --%>
              <div class="absolute inset-0 bg-gradient-to-t from-black/40 via-transparent to-transparent pointer-events-none"></div>
            </div>
          </div>

          <%!-- Identity — right --%>
          <div class="pt-0 md:pt-4">
            <%!-- Role badge --%>
            <div class="flex flex-wrap gap-2 mb-7">
              <span class="inline-flex items-center gap-1.5 text-[11px] font-black uppercase tracking-[0.15em] px-3.5 py-1.5 rounded-full bg-primary/15 border border-primary/25 text-primary">
                <.icon name="hero-code-bracket" class="size-3.5" />
                {@member.role}
              </span>
              <span class="inline-flex items-center gap-1.5 text-[11px] font-black uppercase tracking-[0.15em] px-3.5 py-1.5 rounded-full bg-white/[0.07] border border-white/[0.10] text-base-content/50">
                <.icon name="hero-building-office-2" class="size-3.5" />
                Innoso Team
              </span>
            </div>

            <%!-- Name: "I'm [First]" + "[Rest]" --%>
            <h1 class="font-black tracking-tight leading-[1.05] mb-6">
              <span class="block text-4xl sm:text-5xl lg:text-6xl text-base-content/85">
                {gettext("I'm")}
                <span class="text-primary"> {@first_name}</span>
              </span>
              <span :if={@rest_name != ""} class="block text-4xl sm:text-5xl lg:text-6xl text-base-content">
                {@rest_name}
              </span>
            </h1>

            <%!-- Bio --%>
            <p :if={@member.bio} class="text-base-content/55 leading-[1.8] text-base mb-10 max-w-xl">
              {@member.bio}
            </p>
            <div :if={!@member.bio} class="mb-10"></div>

            <%!-- CTA buttons --%>
            <div class="flex flex-wrap gap-3">
              <.link
                navigate={~p"/#projects"}
                class="inline-flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-bold border border-white/[0.15] text-base-content/70 hover:text-base-content hover:border-white/30 hover:bg-white/[0.05] transition-all"
              >
                <.icon name="hero-folder-open" class="size-4" />
                {gettext("View Projects")}
              </.link>
              <a
                href="/#booking"
                class="inline-flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-bold border border-primary/30 bg-primary/10 text-primary hover:bg-primary/15 hover:border-primary/40 transition-all"
              >
                <.icon name="hero-envelope" class="size-4" />
                {gettext("Get in Touch")}
              </a>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══ SKILLS ═══ --%>
      <section :if={@skills != []} class="border-t border-white/[0.07] px-4 sm:px-6 lg:px-8 py-16">
        <div class="max-w-5xl mx-auto">
          <h2 class="text-3xl sm:text-4xl font-black tracking-tight mb-2">
            {gettext("Skills")} &amp; <span class="text-primary">{gettext("Technologies")}</span>
          </h2>
          <p class="text-base-content/38 text-sm mb-10">{gettext("Tools and technologies I work with")}</p>

          <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
            <div
              :for={{skill, i} <- Enum.with_index(@skills)}
              class="flex items-center gap-3.5 px-4 py-3.5 rounded-xl border border-white/[0.07] bg-base-200/60 hover:border-primary/25 hover:bg-primary/5 transition-all cursor-default group"
            >
              <div class={[
                "w-8 h-8 rounded-lg flex items-center justify-center shrink-0 text-xs font-black transition-colors",
                skill_color(i)
              ]}>
                {String.slice(skill, 0, 2)}
              </div>
              <span class="text-sm font-semibold text-base-content/65 group-hover:text-base-content/90 transition-colors">
                {skill}
              </span>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══ GET IN TOUCH ═══ --%>
      <section class="border-t border-white/[0.07] px-4 sm:px-6 lg:px-8 py-16">
        <div class="max-w-5xl mx-auto">
          <h2 class="text-3xl sm:text-4xl font-black tracking-tight mb-2">
            {gettext("Get in")} <span class="text-primary">{gettext("Touch")}</span>
          </h2>
          <p class="text-base-content/38 text-sm mb-10">
            {gettext("Open to collaborations and new projects")}
          </p>

          <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <%!-- Email --%>
            <a
              href="mailto:codesavvylabs@gmail.com"
              class="flex items-center gap-4 p-5 rounded-xl border border-white/[0.07] bg-base-200/60 hover:border-primary/25 hover:bg-primary/5 transition-all group"
            >
              <div class="w-10 h-10 rounded-lg bg-violet-500/20 border border-violet-500/25 flex items-center justify-center shrink-0">
                <.icon name="hero-envelope" class="size-5 text-violet-400" />
              </div>
              <div class="min-w-0">
                <p class="text-[10px] font-black text-base-content/35 uppercase tracking-widest mb-0.5">Email</p>
                <p class="text-xs font-semibold text-base-content/65 group-hover:text-base-content/90 transition-colors truncate">
                  codesavvylabs@gmail.com
                </p>
              </div>
            </a>

            <%!-- Book a Call --%>
            <a
              href="/#booking"
              class="flex items-center gap-4 p-5 rounded-xl border border-white/[0.07] bg-base-200/60 hover:border-primary/25 hover:bg-primary/5 transition-all group"
            >
              <div class="w-10 h-10 rounded-lg bg-blue-500/20 border border-blue-500/25 flex items-center justify-center shrink-0">
                <.icon name="hero-calendar-days" class="size-5 text-blue-400" />
              </div>
              <div class="min-w-0">
                <p class="text-[10px] font-black text-base-content/35 uppercase tracking-widest mb-0.5">Book a Call</p>
                <p class="text-xs font-semibold text-base-content/65 group-hover:text-base-content/90 transition-colors truncate">
                  {gettext("Free consultation")}
                </p>
              </div>
            </a>

            <%!-- WhatsApp --%>
            <a
              href="https://wa.me/252XXXXXXXXX"
              target="_blank"
              rel="noopener"
              class="flex items-center gap-4 p-5 rounded-xl border border-white/[0.07] bg-base-200/60 hover:border-primary/25 hover:bg-primary/5 transition-all group"
            >
              <div class="w-10 h-10 rounded-lg bg-emerald-500/20 border border-emerald-500/25 flex items-center justify-center shrink-0">
                <svg viewBox="0 0 24 24" fill="currentColor" class="size-5 text-emerald-400" aria-hidden="true">
                  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
                </svg>
              </div>
              <div class="min-w-0">
                <p class="text-[10px] font-black text-base-content/35 uppercase tracking-widest mb-0.5">WhatsApp</p>
                <p class="text-xs font-semibold text-base-content/65 group-hover:text-base-content/90 transition-colors truncate">
                  {gettext("Chat directly")}
                </p>
              </div>
            </a>

            <%!-- Company --%>
            <.link
              navigate={~p"/"}
              class="flex items-center gap-4 p-5 rounded-xl border border-white/[0.07] bg-base-200/60 hover:border-primary/25 hover:bg-primary/5 transition-all group"
            >
              <div class="w-10 h-10 rounded-lg bg-primary/20 border border-primary/25 flex items-center justify-center shrink-0">
                <span class="text-primary font-black text-xs">IN</span>
              </div>
              <div class="min-w-0">
                <p class="text-[10px] font-black text-base-content/35 uppercase tracking-widest mb-0.5">Company</p>
                <p class="text-xs font-semibold text-base-content/65 group-hover:text-base-content/90 transition-colors truncate">
                  Innoso
                </p>
              </div>
            </.link>
          </div>
        </div>
      </section>

      <%!-- ═══ FOOTER ═══ --%>
      <footer class="border-t border-white/[0.07] px-4 sm:px-6 py-8">
        <div class="max-w-5xl mx-auto flex items-center justify-between text-sm text-base-content/30">
          <.link navigate={~p"/"} class="flex items-center gap-2 hover:text-base-content/60 transition-colors font-medium">
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

  @skill_colors [
    "bg-blue-500/20 border border-blue-500/25 text-blue-400",
    "bg-violet-500/20 border border-violet-500/25 text-violet-400",
    "bg-emerald-500/20 border border-emerald-500/25 text-emerald-400",
    "bg-amber-500/20 border border-amber-500/25 text-amber-400",
    "bg-rose-500/20 border border-rose-500/25 text-rose-400",
    "bg-cyan-500/20 border border-cyan-500/25 text-cyan-400",
    "bg-orange-500/20 border border-orange-500/25 text-orange-400",
    "bg-pink-500/20 border border-pink-500/25 text-pink-400",
    "bg-indigo-500/20 border border-indigo-500/25 text-indigo-400",
    "bg-teal-500/20 border border-teal-500/25 text-teal-400"
  ]

  defp skill_color(index) do
    Enum.at(@skill_colors, rem(index, length(@skill_colors)))
  end
end
