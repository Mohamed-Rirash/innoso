defmodule InnosoWeb.HomeLive do
  use InnosoWeb, :live_view

  alias Innoso.Portfolio
  alias Innoso.Team
  alias Innoso.Bookings
  alias Innoso.Scheduling

  @impl true
  def mount(_params, _session, socket) do
    slots = if connected?(socket), do: Scheduling.available_slots_for_weeks(3), else: []
    projects = Portfolio.list_projects()

    all_tags =
      projects
      |> Enum.flat_map(fn p ->
        if p.tags,
          do: p.tags |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == "")),
          else: []
      end)
      |> Enum.uniq()
      |> Enum.sort()

    {:ok,
     socket
     |> assign(:projects, projects)
     |> assign(:all_tags, all_tags)
     |> assign(:filter_tag, nil)
     |> assign(:members, Team.list_members())
     |> assign(:slots, slots)
     |> assign(:services, services())
     |> assign(:steps, steps())
     |> assign(:stats, stats())
     |> assign(:testimonials, testimonials())
     |> assign(:clients, clients())
     |> assign(:faqs, faqs())
     |> assign(:booking_step, :pick_slot)
     |> assign(:selected_slot, nil)
     |> assign(:selected_date, first_available_date(slots))
     |> assign(:booking_form, to_form(%{}, as: :booking))
     |> assign(:mobile_menu_open, false)
     |> assign(:page_title, "Innoso — Modern Tech Solutions")
     |> assign(:page_description, "Innoso is a collective of passionate young developers creating world-class software for businesses, governments, and individuals — built with craftsmanship, delivered with care.")}
  end

  defp services() do
    [
      %{
        icon: "hero-code-bracket",
        title: gettext("Software Development"),
        desc: gettext("We build unique software tailored to your exact needs — from consulting to delivery, with craftsmanship at every step."),
        features: [
          gettext("Software Consulting"),
          gettext("Custom Software Development"),
          gettext("Enterprise Software Development"),
          gettext("Software Maintenance and Support")
        ],
        color: "text-violet-500 dark:text-violet-400",
        bg: "bg-violet-500/10 dark:bg-violet-500/15",
        glow: "bg-violet-500"
      },
      %{
        icon: "hero-device-phone-mobile",
        title: gettext("Mobile App Development"),
        desc: gettext("A high-performance mobile app can engage users and grow your business. We build for iOS and Android."),
        features: [
          gettext("Android App Development"),
          gettext("iOS App Development"),
          gettext("Cross-platform App Development")
        ],
        color: "text-blue-500 dark:text-blue-400",
        bg: "bg-blue-500/10 dark:bg-blue-500/15",
        glow: "bg-blue-500"
      },
      %{
        icon: "hero-globe-alt",
        title: gettext("Web Application Development"),
        desc: gettext("Your website is your digital presence. We build custom web apps that are fast, user-friendly, and beautifully crafted."),
        features: [
          gettext("Custom Web Application Development"),
          gettext("Web Portal Development"),
          gettext("PWA Development"),
          gettext("Ecommerce Web App Development")
        ],
        color: "text-indigo-500 dark:text-indigo-400",
        bg: "bg-indigo-500/10 dark:bg-indigo-500/15",
        glow: "bg-indigo-500"
      },
      %{
        icon: "hero-cube",
        title: gettext("Software Product Development"),
        desc: gettext("From quick MVPs and PoCs to full-blown SaaS products that scale — we partner with you to bring your idea to market."),
        features: [
          gettext("MVP Development"),
          gettext("PoC Development"),
          gettext("SaaS Development")
        ],
        color: "text-sky-500 dark:text-sky-400",
        bg: "bg-sky-500/10 dark:bg-sky-500/15",
        glow: "bg-sky-500"
      },
      %{
        icon: "hero-users",
        title: gettext("Software Development Outsourcing"),
        desc: gettext("Looking to scale your development? We offer flexible outsourcing — from dedicated teams to staff augmentation."),
        features: [
          gettext("Onshore Software Development"),
          gettext("Hire Software Developers"),
          gettext("Dedicated Development Team"),
          gettext("IT Staff Augmentation")
        ],
        color: "text-emerald-500 dark:text-emerald-400",
        bg: "bg-emerald-500/10 dark:bg-emerald-500/15",
        glow: "bg-emerald-500"
      },
      %{
        icon: "hero-cpu-chip",
        title: gettext("AI Development"),
        desc: gettext("We build AI-powered solutions that help your business unlock the potential of the latest technologies."),
        features: [
          gettext("Machine Learning"),
          gettext("Natural Language Processing"),
          gettext("Computer Vision"),
          gettext("Generative AI")
        ],
        color: "text-purple-500 dark:text-purple-400",
        bg: "bg-purple-500/10 dark:bg-purple-500/15",
        glow: "bg-purple-500"
      },
      %{
        icon: "hero-arrow-path",
        title: gettext("Digital Transformation"),
        desc: gettext("We help you find innovative, practical ways to modernize your operations and create better experiences for your customers."),
        features: [
          gettext("Legacy Software Modernization"),
          gettext("Cloud Migration Services"),
          gettext("Data Analytics Services")
        ],
        color: "text-amber-500 dark:text-amber-400",
        bg: "bg-amber-500/10 dark:bg-amber-500/15",
        glow: "bg-amber-500"
      },
      %{
        icon: "hero-server",
        title: gettext("Infrastructure Services"),
        desc: gettext("We keep your IT infrastructure running at peak performance with DevOps and managed services ensuring maximum uptime and security."),
        features: [
          gettext("DevOps Services"),
          gettext("Managed IT Services")
        ],
        color: "text-teal-500 dark:text-teal-400",
        bg: "bg-teal-500/10 dark:bg-teal-500/15",
        glow: "bg-teal-500"
      },
      %{
        icon: "hero-shield-check",
        title: gettext("Software QA Testing"),
        desc: gettext("Launch with confidence. We thoroughly test your applications to guarantee they're reliable, efficient, and free of bugs."),
        features: [
          gettext("QA Outsourcing"),
          gettext("Automation Testing"),
          gettext("Performance Testing"),
          gettext("Functional Testing"),
          gettext("Usability Testing")
        ],
        color: "text-rose-500 dark:text-rose-400",
        bg: "bg-rose-500/10 dark:bg-rose-500/15",
        glow: "bg-rose-500"
      }
    ]
  end

  defp steps() do
    [
      %{
        number: "01",
        phase: gettext("Discovery"),
        title: gettext("Discovery & Strategy"),
        desc: gettext("We start by understanding your business, goals, and users through structured conversations — ensuring we plan and build exactly what you need before a single line of code is written."),
        icon: "hero-magnifying-glass",
        deliverables: [
          gettext("Requirements & scope definition"),
          gettext("Technical architecture plan"),
          gettext("Project timeline & milestones"),
          gettext("Transparent cost estimate")
        ],
        color: "text-violet-500 dark:text-violet-400",
        bg: "bg-violet-500/10 dark:bg-violet-500/15",
        glow: "bg-violet-500"
      },
      %{
        number: "02",
        phase: gettext("Build"),
        title: gettext("Design & Development"),
        desc: gettext("Our team designs and builds in focused sprints with continuous feedback loops — so you see real progress every week and can steer direction at any point."),
        icon: "hero-wrench-screwdriver",
        deliverables: [
          gettext("UI/UX design & prototyping"),
          gettext("Agile development sprints"),
          gettext("Weekly demos & updates"),
          gettext("Automated QA & testing")
        ],
        color: "text-primary",
        bg: "bg-primary/10 dark:bg-primary/15",
        glow: "bg-primary"
      },
      %{
        number: "03",
        phase: gettext("Launch"),
        title: gettext("Launch & Growth"),
        desc: gettext("We deploy your product to production, ensure everything runs flawlessly, and stay by your side as you scale — handling updates, performance, and new feature delivery."),
        icon: "hero-rocket-launch",
        deliverables: [
          gettext("Production deployment"),
          gettext("Performance monitoring"),
          gettext("Ongoing support & maintenance"),
          gettext("Continuous feature delivery")
        ],
        color: "text-secondary",
        bg: "bg-secondary/10 dark:bg-secondary/15",
        glow: "bg-secondary"
      }
    ]
  end

  defp stats() do
    [
      %{value: "50+", label: gettext("Projects Delivered")},
      %{value: "30+", label: gettext("Happy Clients")},
      %{value: "5+",  label: gettext("Countries Served")},
      %{value: "100%", label: gettext("Satisfaction")}
    ]
  end

  defp clients() do
    [
      "StartupHub",
      "GovTech Solutions",
      "Nexus Group",
      "Retail Plus",
      "HealthSync",
      "EduFlow",
      "FinCore",
      "Mobilize Inc."
    ]
  end

  defp testimonials() do
    [
      %{
        quote: gettext("Innoso delivered our platform in record time without cutting corners. The code quality and attention to detail were outstanding — our team was genuinely impressed."),
        name: "Ahmed Hassan",
        role: gettext("CEO"),
        company: "StartupHub",
        rating: 5,
        initials: "AH"
      },
      %{
        quote: gettext("Working with Innoso felt like having a senior engineering team embedded in our company. They understood our vision from day one and executed flawlessly."),
        name: "Mariam Al-Farsi",
        role: gettext("Product Manager"),
        company: "Nexus Group",
        rating: 5,
        initials: "MA"
      },
      %{
        quote: gettext("Our mobile app went from idea to App Store in 10 weeks. The communication was transparent, the process was smooth, and the final product exceeded expectations."),
        name: "Jean-Paul Moreau",
        role: gettext("Founder"),
        company: "EduFlow",
        rating: 5,
        initials: "JM"
      },
      %{
        quote: gettext("We hired Innoso for a legacy modernization project that three other agencies had declined. They tackled it head-on and delivered a clean, maintainable codebase."),
        name: "Fatuma Warsame",
        role: gettext("CTO"),
        company: "FinCore",
        rating: 5,
        initials: "FW"
      },
      %{
        quote: gettext("Responsive, professional, and technically sharp. They built our government portal on schedule and provided excellent documentation and training for our internal team."),
        name: "David Ochieng",
        role: gettext("IT Director"),
        company: "GovTech Solutions",
        rating: 5,
        initials: "DO"
      },
      %{
        quote: gettext("The AI feature Innoso integrated into our platform became our most-used product differentiator. They didn't just write code — they genuinely improved our product strategy."),
        name: "Sofia Benali",
        role: gettext("VP Engineering"),
        company: "HealthSync",
        rating: 5,
        initials: "SB"
      }
    ]
  end

  defp faqs() do
    [
      %{
        q: gettext("How long does a typical project take?"),
        a: gettext("It depends on scope and complexity. A focused MVP typically takes 4–8 weeks. A full product with custom backend, mobile app, and integrations usually runs 3–6 months. We'll give you a precise timeline after the discovery call — no vague estimates.")
      },
      %{
        q: gettext("Do you work with early-stage startups?"),
        a: gettext("Absolutely. Many of our clients come to us with an idea and no technical co-founder. We help validate scope, build an MVP, and iterate based on real user feedback. We're comfortable working with limited budgets as long as the project has clear goals.")
      },
      %{
        q: gettext("What does your pricing look like?"),
        a: gettext("We work on both fixed-scope contracts and time-and-materials engagements. Fixed price works well when requirements are well-defined. T&M is better for evolving products. We're transparent about costs from day one — no surprise invoices.")
      },
      %{
        q: gettext("Do you sign NDAs?"),
        a: gettext("Yes, always. We sign a mutual NDA before any detailed technical or business discussions. Your IP stays yours — we never reuse client-specific code or share project details without explicit permission.")
      },
      %{
        q: gettext("Will I own the code at the end?"),
        a: gettext("100%. All code, designs, and assets we produce for you are fully transferred to you at project completion. We retain no licensing rights or backdoors. You can host it anywhere, hire any team to maintain it, or sell the product — it's entirely yours.")
      },
      %{
        q: gettext("What happens after the project launches?"),
        a: gettext("We offer ongoing support and maintenance packages. Even without a formal package, we stand behind our work and fix critical bugs at no charge within 30 days of launch. Most clients stay with us long-term for new features and iterations.")
      },
      %{
        q: gettext("What technologies do you use?"),
        a: gettext("We choose the best tool for the job — not the trendiest one. Our core strengths are Elixir/Phoenix, React, React Native, Flutter, Node.js, and Python. For AI projects we work with OpenAI, Anthropic, and open-source LLMs. We'll recommend a stack based on your specific requirements.")
      }
    ]
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100 antialiased overflow-x-hidden pt-[68px]">

      <%!-- Ambient background orbs — deeper and richer --%>
      <div aria-hidden="true" class="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
        <div class="absolute -top-[500px] -left-[250px] w-[1100px] h-[1100px] rounded-full bg-violet-600/7 dark:bg-violet-500/25 blur-[180px]"></div>
        <div class="absolute top-[15%] -right-[350px] w-[950px] h-[950px] rounded-full bg-indigo-500/5 dark:bg-blue-500/18 blur-[160px]"></div>
        <div class="absolute bottom-[10%] -left-[150px] w-[800px] h-[800px] rounded-full bg-cyan-400/4 dark:bg-cyan-400/14 blur-[150px]"></div>
        <div class="absolute top-[55%] right-[5%] w-[700px] h-[700px] rounded-full bg-pink-500/3 dark:bg-fuchsia-500/12 blur-[130px]"></div>
        <div class="absolute bottom-[30%] left-[40%] w-[500px] h-[500px] rounded-full dark:bg-violet-600/8 blur-[120px]"></div>
      </div>

      <%!-- ═══════════════════ NAVBAR ═══════════════════ --%>
      <header class="fixed top-0 inset-x-0 z-50" data-smart-nav>
        <nav class="bg-white/70 dark:bg-base-100/60 backdrop-blur-3xl border-b border-black/[0.06] dark:border-white/[0.07] px-4 sm:px-6 lg:px-8">
          <div class="max-w-7xl mx-auto h-[68px] flex items-center gap-4">
            <%!-- Logo --%>
            <a href="/" class="flex items-center gap-3 shrink-0 group">
              <div class="relative w-9 h-9">
                <div class="absolute inset-0 rounded-xl bg-gradient-to-br from-primary to-secondary opacity-0 group-hover:opacity-100 blur-md transition-opacity duration-300"></div>
                <div class="relative w-9 h-9 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-lg shadow-primary/25 group-hover:scale-[1.06] transition-transform duration-200">
                  <span class="text-white font-black text-sm select-none tracking-tight">IN</span>
                </div>
              </div>
              <span class="font-black text-xl tracking-tight">Innoso</span>
            </a>

            <%!-- Desktop nav --%>
            <ul class="hidden md:flex items-center gap-1 flex-1 justify-center">
              <li :for={{label, href} <- [{gettext("About"), "#about"}, {gettext("Services"), "#services"}, {gettext("Projects"), "#projects"}, {gettext("Team"), "#team"}]}>
                <a href={href} class="relative px-4 py-2 text-sm font-semibold text-base-content/55 hover:text-base-content transition-colors duration-150 rounded-lg hover:bg-black/[0.04] dark:hover:bg-white/[0.05]">
                  {label}
                </a>
              </li>
              <li>
                <.link navigate={~p"/blog"} class="relative px-4 py-2 text-sm font-semibold text-base-content/55 hover:text-base-content transition-colors duration-150 rounded-lg hover:bg-black/[0.04] dark:hover:bg-white/[0.05]">
                  {gettext("Blog")}
                </.link>
              </li>
            </ul>

            <%!-- Right controls --%>
            <div class="flex items-center gap-2 ml-auto md:ml-0">
              <div class="dropdown dropdown-end">
                <div tabindex="0" role="button" class="btn btn-ghost btn-sm gap-1.5 rounded-xl text-base-content/55 hover:text-base-content font-semibold text-xs">
                  <.icon name="hero-language" class="size-4" />
                  <span class="hidden sm:inline uppercase">{@locale}</span>
                </div>
                <ul tabindex="0" class="dropdown-content menu z-20 w-44 p-2 mt-2 rounded-2xl bg-white/95 dark:bg-base-200/95 backdrop-blur-2xl border border-black/[0.07] dark:border-white/[0.10] shadow-2xl">
                  <li><.link href={~p"/locale/en"} class="rounded-xl text-sm font-semibold">🇺🇸 English</.link></li>
                  <li><.link href={~p"/locale/ar"} class="rounded-xl text-sm font-semibold">🇸🇦 العربية</.link></li>
                  <li><.link href={~p"/locale/so"} class="rounded-xl text-sm font-semibold">🇸🇴 Soomaali</.link></li>
                  <li><.link href={~p"/locale/fr"} class="rounded-xl text-sm font-semibold">🇫🇷 Français</.link></li>
                </ul>
              </div>
              <Layouts.theme_toggle />
              <a href="#booking" class="hidden md:inline-flex items-center gap-1.5 px-5 py-2 text-sm font-bold rounded-xl text-white bg-gradient-to-r from-primary to-secondary shadow-lg shadow-primary/20 hover:shadow-primary/35 hover:scale-[1.02] transition-all duration-200">
                {gettext("Book a Call")}
                <.icon name="hero-arrow-right" class="size-3.5" />
              </a>
              <button phx-click="toggle_menu" class="md:hidden btn btn-ghost btn-sm btn-square rounded-xl">
                <.icon :if={!@mobile_menu_open} name="hero-bars-3" class="size-5" />
                <.icon :if={@mobile_menu_open} name="hero-x-mark" class="size-5" />
              </button>
            </div>
          </div>
        </nav>

        <%!-- Mobile menu --%>
        <div :if={@mobile_menu_open} class="md:hidden bg-white/95 dark:bg-base-100/95 backdrop-blur-3xl border-b border-black/[0.06] dark:border-white/[0.07] shadow-2xl">
          <div class="max-w-7xl mx-auto px-4 py-3 space-y-0.5">
            <a href="#about" phx-click="close_menu" class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-semibold text-base-content/60 hover:text-base-content hover:bg-black/[0.04] dark:hover:bg-white/[0.06] transition-colors">
              <.icon name="hero-user-group" class="size-4 text-primary/70" /> {gettext("About")}
            </a>
            <a href="#services" phx-click="close_menu" class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-semibold text-base-content/60 hover:text-base-content hover:bg-black/[0.04] dark:hover:bg-white/[0.06] transition-colors">
              <.icon name="hero-squares-2x2" class="size-4 text-primary/70" /> {gettext("Services")}
            </a>
            <a href="#projects" phx-click="close_menu" class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-semibold text-base-content/60 hover:text-base-content hover:bg-black/[0.04] dark:hover:bg-white/[0.06] transition-colors">
              <.icon name="hero-briefcase" class="size-4 text-primary/70" /> {gettext("Projects")}
            </a>
            <a href="#team" phx-click="close_menu" class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-semibold text-base-content/60 hover:text-base-content hover:bg-black/[0.04] dark:hover:bg-white/[0.06] transition-colors">
              <.icon name="hero-users" class="size-4 text-primary/70" /> {gettext("Team")}
            </a>
            <.link navigate={~p"/blog"} phx-click="close_menu" class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-semibold text-base-content/60 hover:text-base-content hover:bg-black/[0.04] dark:hover:bg-white/[0.06] transition-colors">
              <.icon name="hero-pencil-square" class="size-4 text-primary/70" /> {gettext("Blog")}
            </.link>
            <div class="pt-2 pb-1 border-t border-black/[0.06] dark:border-white/[0.07]">
              <a href="#booking" phx-click="close_menu" class="flex items-center justify-center gap-2 w-full py-3 rounded-xl font-bold text-sm text-white bg-gradient-to-r from-primary to-secondary shadow-lg shadow-primary/20">
                {gettext("Book a Free Call")} <.icon name="hero-arrow-right" class="size-4" />
              </a>
            </div>
          </div>
        </div>
      </header>

      <%!-- ═══════════════════ HERO ═══════════════════ --%>
      <section class="relative px-4 sm:px-6 lg:px-8 pt-20 pb-28 lg:pt-32 lg:pb-40 min-h-[94vh] flex items-center">
        <div class="max-w-7xl mx-auto w-full grid lg:grid-cols-2 gap-14 lg:gap-24 items-center">
          <div>
            <%!-- Badge --%>
            <div class="inline-flex items-center gap-2.5 rounded-full px-4 py-2 text-xs font-bold uppercase tracking-widest mb-9 border bg-primary/8 dark:bg-primary/12 border-primary/20 dark:border-primary/30 text-primary">
              <span class="relative flex h-2 w-2">
                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                <span class="relative inline-flex rounded-full h-2 w-2 bg-primary"></span>
              </span>
              {gettext("Youth-Powered · Innovation-Driven")}
            </div>

            <%!-- Headline --%>
            <h1 class="text-[3.75rem] sm:text-[4.75rem] lg:text-[5.25rem] xl:text-[5.75rem] font-black tracking-[-0.02em] leading-[0.96] mb-8">
              <span class="text-base-content">{gettext("We Build")}</span><br />
              <span class="bg-gradient-to-r from-primary via-violet-500 to-secondary bg-clip-text text-transparent">
                {gettext("Tech That")}
              </span><br />
              <span class="text-base-content">{gettext("Matters")}</span>
            </h1>

            <p class="text-lg sm:text-xl text-base-content/50 leading-[1.7] mb-11 max-w-[480px] font-medium">
              {gettext("Innoso is a collective of passionate young developers creating world-class software for businesses, governments, and individuals — built with craftsmanship, delivered with care.")}
            </p>

            <%!-- CTAs --%>
            <div class="flex flex-wrap gap-3 mb-16">
              <a href="#booking" class="inline-flex items-center gap-2 px-7 py-3.5 text-base font-black rounded-2xl text-white bg-gradient-to-r from-primary to-secondary shadow-xl shadow-primary/30 hover:shadow-primary/45 hover:scale-[1.02] transition-all duration-200">
                {gettext("Book a Free Call")}
                <.icon name="hero-arrow-right" class="size-5" />
              </a>
              <a href="#projects" class="inline-flex items-center gap-2 px-7 py-3.5 text-base font-bold rounded-2xl text-base-content bg-white/60 dark:bg-white/[0.07] backdrop-blur-sm border border-black/[0.08] dark:border-white/[0.12] hover:bg-white/80 dark:hover:bg-white/[0.10] hover:border-black/[0.12] dark:hover:border-white/[0.18] transition-all duration-200">
                {gettext("See Our Work")}
              </a>
            </div>

            <%!-- Stats --%>
            <div class="flex flex-wrap gap-x-10 gap-y-4">
              <div :for={stat <- @stats}>
                <div class="text-3xl font-black bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent leading-none tabular-nums">
                  {stat.value}
                </div>
                <div class="text-[10px] font-bold text-base-content/40 uppercase tracking-[0.15em] mt-1.5">
                  {stat.label}
                </div>
              </div>
            </div>
          </div>

          <%!-- Hero terminal --%>
          <div class="hidden lg:flex items-center justify-center">
            <div class="relative w-full max-w-[440px]">
              <%!-- Outer glow --%>
              <div class="absolute -inset-6 bg-gradient-to-br from-primary/30 via-violet-500/20 to-secondary/25 rounded-[2.5rem] blur-3xl pointer-events-none"></div>
              <%!-- Terminal window --%>
              <div class="relative bg-white/75 dark:bg-white/[0.04] backdrop-blur-3xl border border-black/[0.08] dark:border-white/[0.10] rounded-2xl overflow-hidden shadow-2xl">
                <%!-- Title bar --%>
                <div class="flex items-center gap-2 px-5 py-4 border-b border-black/[0.06] dark:border-white/[0.07]">
                  <div class="w-3 h-3 rounded-full bg-red-400"></div>
                  <div class="w-3 h-3 rounded-full bg-yellow-400"></div>
                  <div class="w-3 h-3 rounded-full bg-emerald-400"></div>
                  <div class="flex-1 mx-3">
                    <div class="bg-black/[0.06] dark:bg-white/[0.06] rounded-md px-3 py-1 text-center">
                      <span class="text-[11px] text-base-content/35 font-mono">innoso.ex</span>
                    </div>
                  </div>
                </div>
                <%!-- Code --%>
                <div class="p-7 font-mono text-[13px] leading-[1.85]">
                  <p><span class="text-secondary font-bold">defmodule</span> <span class="text-primary font-bold">Innoso</span> <span class="text-secondary font-bold">do</span></p>
                  <p class="pl-6 text-base-content/40">@mission <span class="text-emerald-500 dark:text-emerald-400">"Build great software"</span></p>
                  <p class="pl-6 text-base-content/40">@values  <span class="text-amber-400">[:quality, :care, :speed]</span></p>
                  <p class="pl-6 mt-1"><span class="text-secondary font-bold">def</span> <span class="text-blue-400 font-bold">deliver</span><span class="text-base-content/40">(project) </span><span class="text-secondary font-bold">do</span></p>
                  <p class="pl-12 text-base-content/30 italic text-[11px]"># on time, every time</p>
                  <p class="pl-12 text-primary font-bold">:success</p>
                  <p class="pl-6 text-secondary font-bold">end</p>
                  <p class="text-secondary font-bold">end</p>
                  <p class="mt-3 flex items-center gap-2">
                    <span class="text-base-content/25 text-xs">iex(1)&gt;</span>
                    <span class="text-emerald-400 text-xs">Innoso.deliver(your_project)</span>
                  </p>
                  <p class="flex items-center gap-2">
                    <span class="text-base-content/25 text-xs">#=&gt;</span>
                    <span class="text-primary font-bold text-xs">:success</span>
                    <span class="inline-block w-2 h-4 bg-primary/80 animate-pulse rounded-sm ml-1"></span>
                  </p>
                </div>
              </div>
              <%!-- Floating badges --%>
              <div class="absolute -top-4 -right-5 flex items-center gap-2 bg-emerald-500 text-white text-xs font-bold rounded-xl px-3.5 py-2.5 shadow-xl shadow-emerald-500/35">
                <.icon name="hero-check-circle" class="size-4" />
                {gettext("Always on time")}
              </div>
              <div class="absolute -bottom-4 -left-5 flex items-center gap-2 bg-white/90 dark:bg-white/[0.09] backdrop-blur-2xl border border-black/[0.08] dark:border-white/[0.14] text-xs font-bold rounded-xl px-3.5 py-2.5 shadow-xl">
                <span class="relative flex h-2.5 w-2.5">
                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                  <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
                </span>
                {gettext("Available now")}
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ TRUSTED BY ═══════════════════ --%>
      <section class="py-16 border-y border-black/[0.05] dark:border-white/[0.06]">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <p class="text-center text-[10px] font-black uppercase tracking-[0.22em] text-base-content/25 mb-10">
            {gettext("Trusted by teams worldwide")}
          </p>
          <div class="flex flex-wrap items-center justify-center gap-x-12 gap-y-6">
            <span
              :for={client <- @clients}
              class="text-base-content/18 dark:text-base-content/12 hover:text-base-content/45 dark:hover:text-base-content/30 transition-colors duration-300 font-black text-lg tracking-tight select-none cursor-default"
            >
              {client}
            </span>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ ABOUT ═══════════════════ --%>
      <section id="about" class="px-4 sm:px-6 lg:px-8 py-28">
        <div class="max-w-6xl mx-auto">
          <div class="text-center mb-18">
            <span class="inline-flex items-center gap-2 text-xs font-bold text-primary uppercase tracking-[0.15em] bg-primary/8 dark:bg-primary/12 border border-primary/18 dark:border-primary/28 px-4 py-1.5 rounded-full mb-6">
              <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
              {gettext("Who We Are")}
            </span>
            <h2 class="text-4xl sm:text-5xl lg:text-6xl font-black tracking-[-0.02em] mb-5 leading-[1.0]">
              {gettext("Built Different.")}
              <span class="bg-gradient-to-r from-primary via-violet-500 to-secondary bg-clip-text text-transparent">
                {" "}{gettext("By Design.")}
              </span>
            </h2>
            <p class="text-base-content/48 max-w-md mx-auto text-lg leading-relaxed font-medium">
              {gettext("A group of talented young developers united by one mission: making technology accessible, impactful, and beautiful.")}
            </p>
          </div>

          <div class="grid md:grid-cols-2 gap-4">
            <%!-- Mission --%>
            <div class="group relative rounded-2xl overflow-hidden transition-all duration-300 hover:-translate-y-1.5 card-glass p-8">
              <div class="absolute inset-0 bg-gradient-to-br from-primary/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none"></div>
              <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-primary opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <div class="absolute -bottom-5 left-1/2 -translate-x-1/2 w-1/2 h-16 bg-primary/30 blur-2xl opacity-0 group-hover:opacity-100 transition-all duration-500 pointer-events-none"></div>
              <div class="relative">
                <div class="w-14 h-14 rounded-2xl bg-primary/10 dark:bg-primary/15 border border-primary/15 dark:border-primary/20 flex items-center justify-center mb-7 group-hover:scale-110 transition-transform duration-300">
                  <.icon name="hero-rocket-launch" class="size-7 text-primary" />
                </div>
                <h3 class="text-2xl font-black mb-4 tracking-tight">{gettext("Our Mission")}</h3>
                <p class="text-base-content/55 leading-relaxed text-[15px]">
                  {gettext("To empower businesses, governments, and individuals by delivering high-quality, modern software that solves real problems — built with craftsmanship, delivered with care.")}
                </p>
              </div>
            </div>

            <%!-- Vision --%>
            <div class="group relative rounded-2xl overflow-hidden transition-all duration-300 hover:-translate-y-1.5 card-glass p-8">
              <div class="absolute inset-0 bg-gradient-to-br from-secondary/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none"></div>
              <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-secondary opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <div class="absolute -bottom-5 left-1/2 -translate-x-1/2 w-1/2 h-16 bg-secondary/30 blur-2xl opacity-0 group-hover:opacity-100 transition-all duration-500 pointer-events-none"></div>
              <div class="relative">
                <div class="w-14 h-14 rounded-2xl bg-secondary/10 dark:bg-secondary/15 border border-secondary/15 dark:border-secondary/20 flex items-center justify-center mb-7 group-hover:scale-110 transition-transform duration-300">
                  <.icon name="hero-eye" class="size-7 text-secondary" />
                </div>
                <h3 class="text-2xl font-black mb-4 tracking-tight">{gettext("Our Vision")}</h3>
                <p class="text-base-content/55 leading-relaxed text-[15px]">
                  {gettext("To become the most trusted tech partner in our region — where clients choose us not just for our code, but for our commitment to their success and our ability to grow with them.")}
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ SERVICES ═══════════════════ --%>
      <section id="services" class="px-4 sm:px-6 lg:px-8 py-28">
        <div class="max-w-7xl mx-auto">
          <div class="text-center mb-18">
            <span class="inline-flex items-center gap-2 text-xs font-bold text-primary uppercase tracking-[0.15em] bg-primary/8 dark:bg-primary/12 border border-primary/18 dark:border-primary/28 px-4 py-1.5 rounded-full mb-6">
              <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
              {gettext("What We Build")}
            </span>
            <h2 class="text-4xl sm:text-5xl lg:text-6xl font-black tracking-[-0.02em] mb-5 leading-[1.0]">
              {gettext("Every Layer of Your")}
              <span class="bg-gradient-to-r from-primary via-violet-500 to-secondary bg-clip-text text-transparent">
                {" "}{gettext("Digital Stack")}
              </span>
            </h2>
            <p class="text-base-content/48 max-w-md mx-auto text-lg leading-relaxed font-medium">
              {gettext("From idea to launch — we cover every layer of your digital needs with precision and care.")}
            </p>
          </div>

          <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-3.5">
            <div
              :for={service <- @services}
              class="group relative rounded-2xl overflow-hidden transition-all duration-300 hover:-translate-y-1.5 cursor-default flex flex-col card-glass p-6"
            >
              <div class="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none"
                   style={"background: radial-gradient(ellipse at 50% 110%, color-mix(in oklch, var(--color-primary) 10%, transparent), transparent 65%)"}>
              </div>
              <div class={["absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px opacity-0 group-hover:opacity-100 transition-opacity duration-300", service.glow]}></div>
              <div class={["absolute -bottom-5 left-1/2 -translate-x-1/2 w-1/2 h-14 blur-2xl opacity-0 group-hover:opacity-60 transition-all duration-500 pointer-events-none", service.glow]}></div>
              <div class="relative flex flex-col flex-1">
                <div class={["w-12 h-12 rounded-xl flex items-center justify-center mb-5 group-hover:scale-110 transition-transform duration-300 border", service.bg, "border-current/10"]}>
                  <.icon name={service.icon} class={["size-5.5", service.color]} />
                </div>
                <h3 class="font-black text-[15px] mb-2.5 leading-snug tracking-tight">{service.title}</h3>
                <p class="text-sm text-base-content/48 leading-relaxed mb-5">{service.desc}</p>
                <ul class="mt-auto space-y-2">
                  <li :for={feature <- service.features} class="flex items-start gap-2 text-[13px] text-base-content/55">
                    <.icon name="hero-check-circle" class={["size-4 shrink-0 mt-0.5", service.color]} />
                    <span>{feature}</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ PROCESS ═══════════════════ --%>
      <section class="px-4 sm:px-6 lg:px-8 py-28">
        <div class="max-w-6xl mx-auto">
          <div class="text-center mb-20">
            <span class="inline-flex items-center gap-2 text-xs font-bold text-primary uppercase tracking-[0.15em] bg-primary/8 dark:bg-primary/12 border border-primary/18 dark:border-primary/28 px-4 py-1.5 rounded-full mb-6">
              <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
              {gettext("How We Work")}
            </span>
            <h2 class="text-4xl sm:text-5xl lg:text-6xl font-black tracking-[-0.02em] mb-5 leading-[1.0]">
              {gettext("How We Turn")}
              <span class="bg-gradient-to-r from-primary via-violet-500 to-secondary bg-clip-text text-transparent">
                {" "}{gettext("Ideas Into Products")}
              </span>
            </h2>
            <p class="text-base-content/48 max-w-lg mx-auto text-lg leading-relaxed font-medium">
              {gettext("A structured, transparent three-phase process that keeps you in the loop — from the first discovery call to launch day and beyond.")}
            </p>
          </div>

          <div class="relative">
            <%!-- Connector line --%>
            <div aria-hidden="true" class="hidden md:block absolute top-7 left-[16.67%] right-[16.67%] h-px bg-gradient-to-r from-violet-500/30 via-primary/45 to-secondary/30"></div>

            <div class="grid md:grid-cols-3 gap-5">
              <div :for={step <- @steps} class="flex flex-col">
                <%!-- Number badge --%>
                <div class="relative z-10 mb-7 md:self-center">
                  <div class="relative w-14 h-14">
                    <div class="absolute inset-0 rounded-2xl bg-gradient-to-br from-primary to-secondary blur-md opacity-50"></div>
                    <div class="relative w-14 h-14 rounded-2xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-lg shadow-primary/30">
                      <span class="text-white font-black text-lg tracking-tight tabular-nums">{step.number}</span>
                    </div>
                  </div>
                </div>

                <%!-- Card --%>
                <div class="group relative rounded-2xl overflow-hidden transition-all duration-300 hover:-translate-y-1.5 flex-1 flex flex-col card-glass p-6">
                  <div class={["absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px opacity-0 group-hover:opacity-100 transition-opacity duration-300", step.glow]}></div>
                  <div class={["absolute -bottom-5 left-1/2 -translate-x-1/2 w-1/2 h-14 blur-2xl opacity-0 group-hover:opacity-65 transition-all duration-500 pointer-events-none", step.glow]}></div>
                  <div class="relative flex flex-col flex-1">
                    <div class="flex items-center gap-3 mb-5">
                      <div class={["w-10 h-10 rounded-xl flex items-center justify-center shrink-0 group-hover:scale-110 transition-transform duration-300 border border-current/10", step.bg]}>
                        <.icon name={step.icon} class={["size-5", step.color]} />
                      </div>
                      <span class={["text-[11px] font-black uppercase tracking-[0.15em]", step.color]}>{step.phase}</span>
                    </div>
                    <h3 class="font-black text-lg mb-2.5 leading-snug tracking-tight">{step.title}</h3>
                    <p class="text-[13.5px] text-base-content/50 leading-relaxed mb-5">{step.desc}</p>
                    <div class="border-t border-black/[0.06] dark:border-white/[0.07] mb-4"></div>
                    <div class="mt-auto">
                      <p class="text-[10px] font-black uppercase tracking-[0.15em] text-base-content/30 mb-3">{gettext("What You Get")}</p>
                      <ul class="space-y-2">
                        <li :for={item <- step.deliverables} class="flex items-start gap-2 text-[13px] text-base-content/55">
                          <.icon name="hero-check-circle" class={["size-4 shrink-0 mt-0.5", step.color]} />
                          <span>{item}</span>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ TECH STACK ═══════════════════ --%>
      <section class="py-28 overflow-hidden">
        <div class="text-center px-4 sm:px-6 mb-18 max-w-4xl mx-auto">
          <h2 class="text-3xl sm:text-4xl lg:text-5xl font-black tracking-[-0.02em] leading-[1.1] mb-5">
            {gettext("Yes, we cover the tech stack")}
            <br class="hidden sm:block" />
            {gettext("and AI tools you rely on")}<span class="text-primary">.</span>
          </h2>
          <p class="text-base-content/45 text-base sm:text-lg leading-relaxed font-medium">
            {gettext("Expertise in 100+ technologies and programming languages,")}<br />
            {gettext("including the AI coding tools rewriting how software gets built.")}
          </p>
        </div>

        <div class="relative select-none">
          <div aria-hidden="true" class="pointer-events-none absolute inset-y-0 left-0 w-40 z-10 bg-gradient-to-r from-base-100 to-transparent"></div>
          <div aria-hidden="true" class="pointer-events-none absolute inset-y-0 right-0 w-40 z-10 bg-gradient-to-l from-base-100 to-transparent"></div>

          <div class="flex overflow-hidden mb-3">
            <div class="flex items-center gap-12 sm:gap-18 animate-marquee whitespace-nowrap">
              <span :for={tech <- ~w(Node.js Java React .NET Python C# TypeScript Kotlin Swift Go Rust Elixir Django Node.js Java React .NET Python C# TypeScript Kotlin Swift Go Rust Elixir Django)} class="text-5xl sm:text-6xl lg:text-7xl font-black text-base-content/[0.09] dark:text-base-content/[0.06] hover:text-primary/30 dark:hover:text-primary/25 transition-colors duration-500 cursor-default px-2">{tech}</span>
            </div>
          </div>
          <div class="flex overflow-hidden">
            <div class="flex items-center gap-12 sm:gap-18 animate-marquee-reverse whitespace-nowrap">
              <span :for={tech <- ~w(Angular PHP Android iOS Vue.js C++ JavaScript PostgreSQL Redis Docker AWS Flutter Next.js Angular PHP Android iOS Vue.js C++ JavaScript PostgreSQL Redis Docker AWS Flutter Next.js)} class="text-5xl sm:text-6xl lg:text-7xl font-black text-base-content/[0.09] dark:text-base-content/[0.06] hover:text-secondary/30 dark:hover:text-secondary/25 transition-colors duration-500 cursor-default px-2">{tech}</span>
            </div>
          </div>
        </div>

        <div class="text-center mt-16">
          <a href="#services" class="inline-flex items-center gap-2 font-bold text-base-content/45 hover:text-base-content transition-colors duration-200 group">
            {gettext("Our full repertoire")}
            <.icon name="hero-arrow-right" class="size-4 group-hover:translate-x-0.5 transition-transform duration-200" />
          </a>
        </div>
      </section>

      <%!-- ═══════════════════ PROJECTS ═══════════════════ --%>
      <section id="projects" class="px-4 sm:px-6 lg:px-8 py-28">
        <div class="max-w-6xl mx-auto">

          <div :if={@projects == []} class="text-center py-24">
            <div class="w-20 h-20 rounded-2xl card-glass flex items-center justify-center mx-auto mb-5">
              <.icon name="hero-briefcase" class="size-10 text-base-content/25" />
            </div>
            <p class="text-base-content/40 font-bold text-lg">{gettext("Projects coming soon")}</p>
            <p class="text-base-content/30 text-sm mt-1">{gettext("Check back shortly.")}</p>
          </div>

          <div :if={@projects != []}>
            <% [fp | _] = @projects %>

            <%!-- Featured --%>
            <div class="mb-20">
              <div class="mb-10">
                <span class="inline-flex items-center gap-2 text-xs font-bold text-primary uppercase tracking-[0.15em] bg-primary/8 dark:bg-primary/12 border border-primary/18 dark:border-primary/28 px-4 py-1.5 rounded-full mb-4">
                  <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
                  {gettext("Featured Work")}
                </span>
                <h2 class="text-4xl sm:text-5xl font-black tracking-[-0.02em] leading-[1.0]">
                  {gettext("Flagship")}
                  <span class="bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
                    {" "}{gettext("Project")}
                  </span>
                </h2>
                <p class="text-base-content/40 text-sm mt-2 font-medium">{gettext("Flagship work on the modern tech stack")}</p>
              </div>

              <.link navigate={~p"/projects/#{fp.id}"}
                class="group flex flex-col md:flex-row rounded-2xl overflow-hidden card-glass border-black/[0.09] dark:border-white/[0.09] bg-gray-950 dark:bg-gray-950 hover:border-primary/35 transition-all duration-300 shadow-2xl shadow-black/25">
                <div class="md:w-[44%] relative overflow-hidden aspect-video md:aspect-auto md:min-h-[300px] shrink-0">
                  <img :if={fp.cover_image} src={fp.cover_image} alt={fp.name} class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700" />
                  <div :if={!fp.cover_image} class="w-full h-full bg-gradient-to-br from-primary/25 via-violet-900/40 to-secondary/20 flex items-center justify-center">
                    <.icon name="hero-briefcase" class="size-16 text-white/10" />
                  </div>
                  <span class="absolute top-4 left-4 text-[10px] font-black uppercase tracking-[0.15em] px-3 py-1.5 rounded-full bg-primary text-white shadow-lg shadow-primary/35">
                    {gettext("Featured")}
                  </span>
                  <div class="absolute top-4 right-4 flex gap-1.5">
                    <span :if={fp.live_url} class="flex items-center gap-1.5 text-[10px] font-bold px-2.5 py-1 rounded-full bg-emerald-500 text-white">
                      <span class="w-1 h-1 rounded-full bg-white animate-pulse"></span>{gettext("Live")}
                    </span>
                    <span :if={fp.demo_credentials != []} class="text-[10px] font-bold px-2.5 py-1 rounded-full bg-amber-500 text-white">{gettext("Demo")}</span>
                  </div>
                </div>
                <div class="md:w-[56%] p-8 sm:p-10 flex flex-col justify-center">
                  <div :if={fp.tags} class="flex flex-wrap items-center gap-1.5 text-xs font-bold text-white/35 mb-5">
                    <span :for={{tag, i} <- fp.tags |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.take(4) |> Enum.with_index()}>
                      <span :if={i > 0} class="mx-1 text-white/15">·</span>{tag}
                    </span>
                  </div>
                  <h3 class="text-2xl sm:text-3xl font-black text-white mb-4 leading-snug tracking-tight group-hover:text-primary transition-colors duration-200">{fp.name}</h3>
                  <p class="text-white/45 leading-relaxed mb-7 line-clamp-4 text-[14px]">{InnosoWeb.Markdown.plain_text(fp.description)}</p>
                  <div :if={fp.tags} class="flex flex-wrap gap-2 mb-8">
                    <span :for={tag <- fp.tags |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.take(6)}
                      class="text-[11px] font-semibold px-2.5 py-1 rounded-full bg-white/[0.07] border border-white/[0.09] text-white/45 hover:border-primary/35 hover:text-primary transition-colors">{tag}</span>
                  </div>
                  <span class="inline-flex items-center gap-2 font-bold text-primary text-sm w-fit px-5 py-2.5 rounded-xl bg-primary/12 border border-primary/22 group-hover:bg-primary/18 transition-colors">
                    <.icon name="hero-globe-alt" class="size-4" />{gettext("View Case Study")}
                  </span>
                </div>
              </.link>
            </div>

            <%!-- All Projects --%>
            <div>
              <div class="mb-10">
                <h2 class="text-4xl sm:text-5xl font-black tracking-[-0.02em] leading-[1.0]">
                  {gettext("All")}
                  <span class="bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">{" "}{gettext("Projects")}</span>
                </h2>
                <p class="text-base-content/40 text-sm mt-2 font-medium">{gettext("Software solutions across industries and borders")}</p>
              </div>

              <div :if={@all_tags != []} class="flex flex-wrap gap-2 mb-8">
                <button phx-click="filter_tag" phx-value-tag=""
                  class={["text-xs font-bold px-4 py-1.5 rounded-full border transition-all duration-150",
                    is_nil(@filter_tag) && "bg-primary text-white border-primary shadow-sm shadow-primary/25",
                    !is_nil(@filter_tag) && "border-black/[0.10] dark:border-white/[0.10] text-base-content/50 hover:border-primary/35 hover:text-primary"]}>
                  {gettext("All")}
                </button>
                <button :for={tag <- @all_tags} phx-click="filter_tag" phx-value-tag={tag}
                  class={["text-xs font-bold px-4 py-1.5 rounded-full border transition-all duration-150",
                    @filter_tag == tag && "bg-primary text-white border-primary shadow-sm shadow-primary/25",
                    @filter_tag != tag && "border-black/[0.10] dark:border-white/[0.10] text-base-content/50 hover:border-primary/35 hover:text-primary"]}>
                  {tag}
                </button>
              </div>

              <%
                display_projects = if @filter_tag do
                  Enum.filter(@projects, fn p ->
                    @filter_tag in (if p.tags, do: p.tags |> String.split(",") |> Enum.map(&String.trim/1), else: [])
                  end)
                else
                  @projects
                end
              %>

              <div :if={display_projects == []} class="text-center py-16">
                <p class="text-base-content/40 font-semibold">{gettext("No projects match this filter.")}</p>
                <button phx-click="filter_tag" phx-value-tag="" class="mt-3 text-sm text-primary font-bold hover:underline">{gettext("Clear filter")}</button>
              </div>

              <div :if={display_projects != []} class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
                <.link :for={project <- display_projects} navigate={~p"/projects/#{project.id}"}
                  class="group flex flex-col rounded-2xl overflow-hidden card-glass hover:border-primary/25 dark:hover:border-primary/28 hover:shadow-lg hover:shadow-primary/6 hover:-translate-y-1 transition-all duration-300">
                  <div class="relative aspect-video overflow-hidden shrink-0 bg-base-200 dark:bg-base-300">
                    <img :if={project.cover_image} src={project.cover_image} alt={project.name} class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                    <div :if={!project.cover_image} class="w-full h-full bg-gradient-to-br from-primary/10 to-secondary/10 flex items-center justify-center">
                      <.icon name="hero-briefcase" class="size-10 text-primary/20" />
                    </div>
                    <div class="absolute top-3 right-3 flex gap-1.5">
                      <span :if={project.live_url} class="flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-500 text-white">
                        <span class="w-1 h-1 rounded-full bg-white animate-pulse"></span>{gettext("Live")}
                      </span>
                      <span :if={project.demo_credentials != []} class="text-[10px] font-bold px-2 py-0.5 rounded-full bg-amber-500 text-white">{gettext("Demo")}</span>
                    </div>
                  </div>
                  <div class="flex flex-col flex-1 p-5">
                    <h3 class="font-black text-[15px] leading-snug mb-2 tracking-tight group-hover:text-primary transition-colors">{project.name}</h3>
                    <p class="text-[13px] text-base-content/48 leading-relaxed line-clamp-2 flex-1 mb-4">{InnosoWeb.Markdown.plain_text(project.description)}</p>
                    <div :if={project.tags} class="flex flex-wrap gap-1.5 mb-4">
                      <span :for={tag <- project.tags |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.take(4)}
                        class={["text-[10px] font-semibold px-2.5 py-0.5 rounded-full border transition-colors",
                          @filter_tag == tag && "bg-primary/10 dark:bg-primary/15 border-primary/25 text-primary",
                          @filter_tag != tag && "border-black/[0.09] dark:border-white/[0.09] text-base-content/42"]}>
                        {tag}
                      </span>
                      <span :if={(project.tags |> String.split(",") |> Enum.map(&String.trim/1) |> length()) > 4}
                        class="text-[10px] font-semibold px-2.5 py-0.5 rounded-full border border-black/[0.09] dark:border-white/[0.09] text-base-content/28">
                        +{(project.tags |> String.split(",") |> Enum.map(&String.trim/1) |> length()) - 4}
                      </span>
                    </div>
                    <div class="flex items-center justify-between pt-3 border-t border-black/[0.06] dark:border-white/[0.06]">
                      <span class="text-xs font-bold text-primary inline-flex items-center gap-1.5 group-hover:gap-2.5 transition-all duration-200">
                        {gettext("View Project")} <.icon name="hero-arrow-right" class="size-3.5" />
                      </span>
                      <span class="text-[10px] font-semibold text-base-content/28 capitalize">{project.client_type}</span>
                    </div>
                  </div>
                </.link>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ TEAM ═══════════════════ --%>
      <section id="team" class="px-4 sm:px-6 lg:px-8 py-28">
        <div class="max-w-6xl mx-auto">
          <div class="mb-16">
            <span class="inline-flex items-center gap-2 text-xs font-bold text-primary uppercase tracking-[0.15em] bg-primary/8 dark:bg-primary/12 border border-primary/18 dark:border-primary/28 px-4 py-1.5 rounded-full mb-6">
              <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
              {gettext("The Team")}
            </span>
            <div class="flex items-end justify-between gap-6">
              <h2 class="text-4xl sm:text-5xl lg:text-6xl font-black tracking-[-0.02em] leading-[1.0]">
                {gettext("The people")}<br />
                <span class="bg-gradient-to-r from-primary via-violet-500 to-secondary bg-clip-text text-transparent">
                  {gettext("behind the work.")}
                </span>
              </h2>
              <p class="hidden sm:block text-base-content/42 text-[15px] leading-relaxed max-w-[260px] text-right pb-1 font-medium">
                {gettext("Talented developers who pour creativity and expertise into every project.")}
              </p>
            </div>
          </div>

          <div :if={@members == []} class="text-center py-24">
            <div class="w-20 h-20 rounded-2xl card-glass flex items-center justify-center mx-auto mb-5">
              <.icon name="hero-users" class="size-10 text-base-content/25" />
            </div>
            <p class="text-base-content/40 font-bold text-lg">{gettext("Team profiles coming soon")}</p>
          </div>

          <div :if={@members != []} class="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            <.link :for={member <- @members} navigate={~p"/team/#{member.id}"} id={"member-#{member.id}"}
              class="group flex flex-col rounded-2xl overflow-hidden card-glass hover:border-primary/25 dark:hover:border-primary/28 hover:shadow-xl hover:shadow-primary/6 hover:-translate-y-1.5 transition-all duration-300">
              <%!-- Photo --%>
              <div class="relative pt-8 pb-4 px-6 flex flex-col items-center border-b border-black/[0.06] dark:border-white/[0.06] bg-gradient-to-b from-primary/5 dark:from-primary/8 to-transparent">
                <div class="relative mb-4">
                  <div class="w-24 h-24 rounded-full overflow-hidden ring-4 ring-white/80 dark:ring-base-100/50 shadow-lg group-hover:ring-primary/25 transition-all duration-300">
                    <img :if={member.photo} src={member.photo} alt={member.name} class="w-full h-full object-cover object-top group-hover:scale-110 transition-transform duration-500" />
                    <div :if={!member.photo} class="w-full h-full bg-gradient-to-br from-primary/20 via-violet-500/15 to-secondary/20 flex items-center justify-center">
                      <span class="text-3xl font-black text-primary/50 select-none leading-none">
                        {member.name |> String.split(" ") |> Enum.map(&String.first/1) |> Enum.take(2) |> Enum.join()}
                      </span>
                    </div>
                  </div>
                  <span class="absolute bottom-1 right-1 w-4 h-4 rounded-full bg-emerald-500 border-2 border-white dark:border-base-100 shadow-sm"></span>
                </div>
                <h3 class="font-black text-base text-center leading-snug tracking-tight group-hover:text-primary transition-colors duration-200">{member.name}</h3>
                <p class="text-[11px] font-bold text-primary/65 uppercase tracking-[0.12em] mt-1 text-center">{member.role}</p>
              </div>
              <%!-- Bio + skills --%>
              <div class="p-5 flex flex-col flex-1">
                <p :if={member.bio} class="text-[13px] text-base-content/48 leading-relaxed line-clamp-3 flex-1 mb-4">{member.bio}</p>
                <div :if={!member.bio} class="flex-1"></div>
                <div :if={member.skills} class="flex flex-wrap gap-1.5 mb-4">
                  <span :for={skill <- member.skills |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == "")) |> Enum.take(3)}
                    class="text-[10px] font-semibold px-2.5 py-0.5 rounded-full border border-base-content/[0.09] dark:border-white/[0.09] text-base-content/42">{skill}</span>
                  <span :if={(member.skills |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == "")) |> length()) > 3}
                    class="text-[10px] font-semibold px-2.5 py-0.5 rounded-full border border-base-content/[0.09] dark:border-white/[0.09] text-base-content/30">
                    +{(member.skills |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == "")) |> length()) - 3}
                  </span>
                </div>
                <span class="inline-flex items-center gap-1.5 text-xs font-bold text-primary group-hover:gap-2.5 transition-all duration-200">
                  {gettext("View Profile")} <.icon name="hero-arrow-right" class="size-3.5" />
                </span>
              </div>
            </.link>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ TESTIMONIALS ═══════════════════ --%>
      <section class="px-4 sm:px-6 lg:px-8 py-28">
        <div class="max-w-7xl mx-auto">
          <div class="text-center mb-18">
            <span class="inline-flex items-center gap-2 text-xs font-bold text-primary uppercase tracking-[0.15em] bg-primary/8 dark:bg-primary/12 border border-primary/18 dark:border-primary/28 px-4 py-1.5 rounded-full mb-6">
              <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
              {gettext("Client Stories")}
            </span>
            <h2 class="text-4xl sm:text-5xl lg:text-6xl font-black tracking-[-0.02em] mb-5 leading-[1.0]">
              {gettext("Trusted by")}
              <span class="bg-gradient-to-r from-primary via-violet-500 to-secondary bg-clip-text text-transparent">
                {" "}{gettext("Great Teams")}
              </span>
            </h2>
            <p class="text-base-content/48 max-w-md mx-auto text-lg leading-relaxed font-medium">
              {gettext("Don't take our word for it — here's what our clients say about working with us.")}
            </p>
          </div>

          <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <div :for={t <- @testimonials}
              class="group relative rounded-2xl overflow-hidden transition-all duration-300 hover:-translate-y-1.5 flex flex-col card-glass p-6">
              <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-primary opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <div class="absolute -bottom-5 left-1/2 -translate-x-1/2 w-1/2 h-16 bg-primary/25 blur-2xl opacity-0 group-hover:opacity-100 transition-all duration-500 pointer-events-none"></div>
              <div class="relative flex flex-col flex-1">
                <%!-- Quote mark --%>
                <div class="text-5xl font-black text-primary/15 dark:text-primary/20 leading-none mb-2 select-none">"</div>
                <%!-- Stars --%>
                <div class="flex gap-0.5 mb-4">
                  <span :for={_ <- 1..t.rating//1} class="text-amber-400 text-base leading-none">★</span>
                </div>
                <p class="text-[14px] text-base-content/60 leading-[1.75] flex-1 mb-6">
                  {t.quote}
                </p>
                <div class="flex items-center gap-3 pt-4 border-t border-black/[0.06] dark:border-white/[0.06]">
                  <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary/25 to-secondary/25 flex items-center justify-center shrink-0 ring-2 ring-primary/15">
                    <span class="text-xs font-black text-primary">{t.initials}</span>
                  </div>
                  <div>
                    <p class="font-black text-[13.5px] leading-none mb-1 tracking-tight">{t.name}</p>
                    <p class="text-[11px] text-base-content/40 font-semibold">{t.role} · {t.company}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ CTA BANNER ═══════════════════ --%>
      <section class="px-4 sm:px-6 lg:px-8 py-16">
        <div class="max-w-6xl mx-auto">
          <div class="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary via-violet-600 to-secondary p-px shadow-2xl shadow-primary/30">
            <div class="relative rounded-[calc(1.5rem-1px)] bg-gradient-to-br from-primary via-violet-600 to-secondary px-8 py-20 sm:px-16 text-center overflow-hidden">
              <%!-- Decorative circles --%>
              <div class="absolute -top-24 -right-24 w-80 h-80 rounded-full bg-white/[0.07] pointer-events-none"></div>
              <div class="absolute -bottom-32 -left-32 w-96 h-96 rounded-full bg-white/[0.07] pointer-events-none"></div>
              <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[700px] rounded-full bg-white/[0.025] pointer-events-none"></div>
              <div class="relative">
                <div class="inline-flex items-center gap-2.5 bg-white/12 backdrop-blur-sm border border-white/18 text-white/85 rounded-full px-4 py-2 text-xs font-bold uppercase tracking-[0.15em] mb-8">
                  <span class="relative flex h-2 w-2">
                    <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-white opacity-75"></span>
                    <span class="relative inline-flex rounded-full h-2 w-2 bg-white"></span>
                  </span>
                  {gettext("Free Consultation")}
                </div>
                <h2 class="text-3xl sm:text-4xl lg:text-5xl font-black text-white mb-5 tracking-[-0.02em] leading-[1.05]">
                  {gettext("Ready to Build Something")}<br />{gettext("Amazing Together?")}
                </h2>
                <p class="text-white/60 text-lg mb-10 max-w-xl mx-auto leading-relaxed font-medium">
                  {gettext("Tell us about your project. No commitment required — just a conversation about what you need.")}
                </p>
                <a href="#booking" class="inline-flex items-center gap-2.5 px-8 py-4 text-base font-black rounded-2xl bg-white hover:bg-white/95 text-primary shadow-2xl hover:scale-[1.02] transition-all duration-200">
                  {gettext("Book a Free Call")}
                  <.icon name="hero-arrow-right" class="size-5" />
                </a>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ FAQ ═══════════════════ --%>
      <section class="px-4 sm:px-6 lg:px-8 py-28">
        <div class="max-w-3xl mx-auto">
          <div class="text-center mb-18">
            <span class="inline-flex items-center gap-2 text-xs font-bold text-primary uppercase tracking-[0.15em] bg-primary/8 dark:bg-primary/12 border border-primary/18 dark:border-primary/28 px-4 py-1.5 rounded-full mb-6">
              <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
              {gettext("FAQ")}
            </span>
            <h2 class="text-4xl sm:text-5xl lg:text-6xl font-black tracking-[-0.02em] mb-5 leading-[1.0]">
              {gettext("Common")}
              <span class="bg-gradient-to-r from-primary via-violet-500 to-secondary bg-clip-text text-transparent">
                {" "}{gettext("Questions")}
              </span>
            </h2>
            <p class="text-base-content/48 max-w-md mx-auto text-lg leading-relaxed font-medium">
              {gettext("Everything you need to know before getting started.")}
            </p>
          </div>

          <div class="space-y-2.5">
            <details :for={faq <- @faqs}
              class="group rounded-2xl overflow-hidden transition-all duration-200 card-glass open:border-primary/28 dark:open:border-primary/35">
              <summary class="flex items-center justify-between gap-4 px-6 py-5 cursor-pointer list-none font-bold text-[15px] select-none hover:text-primary transition-colors duration-150">
                <span class="tracking-tight">{faq.q}</span>
                <.icon name="hero-chevron-down" class="size-5 shrink-0 text-base-content/30 group-open:rotate-180 transition-transform duration-200" />
              </summary>
              <div class="px-6 pb-6 pt-0 text-[14px] text-base-content/55 leading-relaxed border-t border-black/[0.06] dark:border-white/[0.07] pt-4">
                {faq.a}
              </div>
            </details>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ BOOKING ═══════════════════ --%>
      <section id="booking" class="px-4 sm:px-6 lg:px-8 pb-32">
        <div class="max-w-2xl mx-auto">
          <div class="text-center mb-14">
            <span class="inline-flex items-center gap-2 text-xs font-bold text-primary uppercase tracking-[0.15em] bg-primary/8 dark:bg-primary/12 border border-primary/18 dark:border-primary/28 px-4 py-1.5 rounded-full mb-6">
              <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
              {gettext("Get Started")}
            </span>
            <h2 class="text-4xl sm:text-5xl font-black tracking-[-0.02em] mb-4 leading-[1.0]">
              {gettext("Book a")}
              <span class="bg-gradient-to-r from-primary via-violet-500 to-secondary bg-clip-text text-transparent">
                {" "}{gettext("Free Call")}
              </span>
            </h2>
            <p class="text-base-content/48 text-lg leading-relaxed font-medium">
              {gettext("Pick a time, share your idea, and we'll take it from there.")}
            </p>
          </div>

          <div class="relative rounded-3xl overflow-hidden card-glass shadow-2xl shadow-black/15">
            <div class="h-[3px] bg-gradient-to-r from-primary via-violet-500 to-secondary"></div>
            <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-2/3 h-px bg-primary opacity-25"></div>
            <div class="absolute -bottom-6 left-1/2 -translate-x-1/2 w-1/2 h-20 bg-primary/15 blur-3xl pointer-events-none"></div>

            <div class="p-8 sm:p-10">
              <%!-- Steps --%>
              <div class="flex items-center gap-2 mb-9">
                <div class={["w-8 h-8 rounded-full flex items-center justify-center text-xs font-black transition-all duration-300",
                  @booking_step == :pick_slot && "bg-gradient-to-br from-primary to-secondary text-white shadow-md shadow-primary/30",
                  @booking_step != :pick_slot && "bg-emerald-500 text-white"]}>
                  {if @booking_step == :pick_slot, do: "1", else: "✓"}
                </div>
                <div class={["flex-1 h-0.5 rounded-full transition-all duration-500",
                  @booking_step == :pick_slot && "bg-black/[0.08] dark:bg-white/[0.08]",
                  @booking_step != :pick_slot && "bg-gradient-to-r from-emerald-500 to-primary"]}></div>
                <div class={["w-8 h-8 rounded-full flex items-center justify-center text-xs font-black transition-all duration-300",
                  @booking_step == :contact && "bg-gradient-to-br from-primary to-secondary text-white shadow-md shadow-primary/30",
                  @booking_step == :success && "bg-emerald-500 text-white",
                  @booking_step == :pick_slot && "bg-black/[0.06] dark:bg-white/[0.07] text-base-content/35"]}>
                  {if @booking_step == :success, do: "✓", else: "2"}
                </div>
              </div>

              <%!-- Step 1 --%>
              <div :if={@booking_step == :pick_slot}>
                <h3 class="font-black text-xl mb-1.5 tracking-tight">{gettext("Choose a time slot")}</h3>
                <p class="text-[14px] text-base-content/42 mb-7 font-medium">{gettext("Pick a date and time that works for you.")}</p>

                <div :if={@slots == []} class="text-center py-14">
                  <div class="w-16 h-16 rounded-2xl card-glass flex items-center justify-center mx-auto mb-4">
                    <.icon name="hero-calendar" class="size-8 text-base-content/30" />
                  </div>
                  <p class="text-base-content/38 font-medium text-sm">{gettext("Loading available slots...")}</p>
                </div>

                <div :if={@slots != []}>
                  <div class="flex gap-2 overflow-x-auto pb-2 -mx-1 px-1 snap-x snap-mandatory mb-7">
                    <button :for={{date, count} <- dates_with_counts(@slots)}
                      phx-click="select_date" phx-value-date={Date.to_string(date)} disabled={count == 0}
                      class={["snap-start flex-none flex flex-col items-center gap-0.5 w-[64px] py-3 rounded-2xl border transition-all duration-200",
                        date == @selected_date && "bg-gradient-to-b from-primary to-secondary text-white border-transparent shadow-lg shadow-primary/30 scale-[1.04]",
                        date != @selected_date && count > 0 && "card-glass hover:border-primary/35 hover:scale-[1.02] cursor-pointer",
                        date != @selected_date && count == 0 && "border-black/[0.04] dark:border-white/[0.04] opacity-30 cursor-not-allowed"]}>
                      <span class={["text-[9px] font-black uppercase tracking-widest",
                        date == @selected_date && "text-white/65", date != @selected_date && "text-base-content/38"]}>
                        {Calendar.strftime(date, "%a")}
                      </span>
                      <span class={["text-[21px] font-black leading-tight tabular-nums",
                        date == @selected_date && "text-white", date != @selected_date && "text-base-content"]}>
                        {date.day}
                      </span>
                      <span class={["text-[9px] font-bold flex items-center gap-0.5 mt-0.5",
                        date == @selected_date && "text-white/55",
                        date != @selected_date && count > 0 && "text-primary/55",
                        date != @selected_date && count == 0 && "text-base-content/22"]}>
                        <span :if={count > 0} class={["w-1 h-1 rounded-full", date == @selected_date && "bg-white/75", date != @selected_date && "bg-primary"]}></span>
                        {count}
                      </span>
                    </button>
                  </div>

                  <div :if={@selected_date != nil} class="space-y-3">
                    <p class="text-[11px] font-black text-base-content/32 uppercase tracking-[0.15em] flex items-center gap-1.5">
                      <.icon name="hero-clock" class="size-3.5" />
                      {Calendar.strftime(@selected_date, "%A, %B %d")}
                    </p>
                    <div class="grid grid-cols-3 sm:grid-cols-4 gap-2">
                      <button :for={slot <- slots_for_date(@slots, @selected_date)}
                        disabled={slot.taken}
                        phx-click="select_slot" phx-value-date={Date.to_string(slot.date)} phx-value-time={Time.to_string(slot.time)}
                        class={["rounded-xl border py-3 text-center text-sm font-bold transition-all duration-150",
                          slot.taken && "opacity-22 cursor-not-allowed line-through text-base-content/28 border-black/[0.04] dark:border-white/[0.04]",
                          !slot.taken && @selected_slot && Date.compare(@selected_slot.date, slot.date) == :eq && Time.compare(@selected_slot.time, slot.time) == :eq && "bg-gradient-to-br from-primary to-secondary text-white border-transparent shadow-lg shadow-primary/30 scale-[1.05]",
                          !slot.taken && !(@selected_slot && Date.compare(@selected_slot.date, slot.date) == :eq && Time.compare(@selected_slot.time, slot.time) == :eq) && "card-glass hover:border-primary/40 hover:text-primary hover:scale-[1.02] cursor-pointer"]}>
                        {format_time(slot.time)}
                      </button>
                    </div>
                  </div>
                </div>

                <button disabled={is_nil(@selected_slot)} phx-click="next_step"
                  class="flex items-center justify-center gap-2 w-full mt-7 py-3.5 text-base font-black rounded-2xl text-white bg-gradient-to-r from-primary to-secondary shadow-lg shadow-primary/22 hover:shadow-primary/35 hover:scale-[1.01] transition-all duration-200 disabled:opacity-38 disabled:cursor-not-allowed disabled:hover:scale-100">
                  {gettext("Continue")} <.icon name="hero-arrow-right" class="size-5" />
                </button>
              </div>

              <%!-- Step 2 --%>
              <div :if={@booking_step == :contact}>
                <div class="flex items-center gap-3 mb-7">
                  <button phx-click="prev_step" class="w-8 h-8 rounded-xl card-glass flex items-center justify-center text-base-content/50 hover:text-base-content transition-colors">
                    <.icon name="hero-arrow-left" class="size-4" />
                  </button>
                  <div>
                    <h3 class="font-black text-xl tracking-tight">{gettext("Your details")}</h3>
                    <p class="text-[12px] text-base-content/38 mt-0.5 flex items-center gap-1.5 font-semibold">
                      <.icon name="hero-calendar-days" class="size-3.5" />
                      {if @selected_slot, do: Calendar.strftime(@selected_slot.date, "%B %d") <> " at " <> format_time(@selected_slot.time)}
                    </p>
                  </div>
                </div>
                <.form for={@booking_form} phx-submit="submit_booking" phx-change="validate_booking">
                  <div class="space-y-4">
                    <.input field={@booking_form[:name]} type="text" label={gettext("Full Name")} required />
                    <.input field={@booking_form[:email]} type="email" label={gettext("Email Address")} required />
                    <.input field={@booking_form[:phone]} type="tel" label={gettext("Phone Number")} required />
                    <.input field={@booking_form[:description]} type="textarea" label={gettext("Tell us about your project")} required />
                    <.button class="flex items-center justify-center gap-2 w-full mt-2 py-3.5 text-base font-black rounded-2xl text-white bg-gradient-to-r from-primary to-secondary shadow-lg shadow-primary/22 hover:opacity-90 border-0" phx-disable-with={gettext("Booking...")}>
                      {gettext("Confirm Booking")} <.icon name="hero-calendar-days" class="size-5" />
                    </.button>
                  </div>
                </.form>
              </div>

              <%!-- Step 3 --%>
              <div :if={@booking_step == :success} class="text-center py-12">
                <div class="relative w-20 h-20 mx-auto mb-7">
                  <div class="absolute inset-0 bg-emerald-500/20 rounded-2xl blur-2xl"></div>
                  <div class="relative w-20 h-20 bg-emerald-500/10 border border-emerald-500/18 rounded-2xl flex items-center justify-center">
                    <.icon name="hero-check-circle" class="size-12 text-emerald-500" />
                  </div>
                </div>
                <h3 class="text-2xl font-black mb-3 tracking-tight">{gettext("You're all set!")}</h3>
                <p class="text-base-content/48 mb-9 leading-relaxed max-w-sm mx-auto text-[15px]">
                  {gettext("We've received your booking. Check your email for confirmation — we'll be in touch shortly.")}
                </p>
                <button phx-click="reset_booking" class="inline-flex items-center gap-2 px-6 py-2.5 rounded-2xl text-sm font-bold border border-black/[0.09] dark:border-white/[0.10] text-base-content/60 hover:text-base-content hover:border-primary/35 transition-all duration-200">
                  <.icon name="hero-plus" class="size-4" /> {gettext("Book Another Meeting")}
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <%!-- ═══════════════════ FOOTER ═══════════════════ --%>
      <footer class="px-4 sm:px-6 lg:px-8 pt-16 pb-10 border-t border-black/[0.05] dark:border-white/[0.06]">
        <div class="max-w-7xl mx-auto">
          <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-10 mb-16">
            <div class="sm:col-span-2 lg:col-span-1">
              <a href="/" class="flex items-center gap-2.5 mb-5 w-fit group">
                <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-md shadow-primary/20 group-hover:scale-105 transition-transform duration-200">
                  <span class="text-white font-black text-sm select-none">IN</span>
                </div>
                <span class="font-black text-xl tracking-tight">Innoso</span>
              </a>
              <p class="text-[13.5px] text-base-content/42 leading-relaxed max-w-xs">
                {gettext("Youth-powered software solutions for businesses, governments, and individuals worldwide.")}
              </p>
            </div>
            <div>
              <h4 class="font-black text-[10px] uppercase tracking-[0.18em] text-base-content/38 mb-5">{gettext("Services")}</h4>
              <ul class="space-y-2.5 text-[13.5px] text-base-content/45">
                <li class="hover:text-base-content transition-colors duration-150 cursor-default">{gettext("Web Applications")}</li>
                <li class="hover:text-base-content transition-colors duration-150 cursor-default">{gettext("Mobile Apps")}</li>
                <li class="hover:text-base-content transition-colors duration-150 cursor-default">{gettext("E-commerce")}</li>
                <li class="hover:text-base-content transition-colors duration-150 cursor-default">{gettext("Enterprise Systems")}</li>
                <li class="hover:text-base-content transition-colors duration-150 cursor-default">{gettext("Tech Consulting")}</li>
              </ul>
            </div>
            <div>
              <h4 class="font-black text-[10px] uppercase tracking-[0.18em] text-base-content/38 mb-5">{gettext("Company")}</h4>
              <ul class="space-y-2.5 text-[13.5px] text-base-content/45">
                <li><a href="#about" class="hover:text-base-content transition-colors duration-150">{gettext("About Us")}</a></li>
                <li><a href="#projects" class="hover:text-base-content transition-colors duration-150">{gettext("Portfolio")}</a></li>
                <li><a href="#team" class="hover:text-base-content transition-colors duration-150">{gettext("Team")}</a></li>
                <li><a href="#booking" class="hover:text-base-content transition-colors duration-150">{gettext("Contact")}</a></li>
              </ul>
            </div>
            <div>
              <h4 class="font-black text-[10px] uppercase tracking-[0.18em] text-base-content/38 mb-5">{gettext("Contact")}</h4>
              <ul class="space-y-3 text-[13.5px] text-base-content/45">
                <li class="flex items-start gap-2.5">
                  <.icon name="hero-envelope" class="size-4 shrink-0 mt-0.5 text-primary/70" />
                  <span class="break-all">codesavvylabs@gmail.com</span>
                </li>
                <li>
                  <a href="https://wa.me/252XXXXXXXXX" target="_blank" rel="noopener" class="flex items-center gap-2.5 text-base-content/45 hover:text-emerald-500 transition-colors duration-150 font-medium">
                    <svg viewBox="0 0 24 24" fill="currentColor" class="size-4 shrink-0" aria-hidden="true">
                      <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
                    </svg>
                    WhatsApp
                  </a>
                </li>
                <li>
                  <a href="#booking" class="flex items-center gap-2.5 text-primary hover:text-primary/75 font-semibold transition-colors duration-150">
                    <.icon name="hero-calendar-days" class="size-4 shrink-0" />
                    {gettext("Book a free meeting")}
                  </a>
                </li>
              </ul>
            </div>
          </div>

          <div class="border-t border-black/[0.05] dark:border-white/[0.06] pt-8 flex flex-col sm:flex-row items-center justify-between gap-5 text-[13px] text-base-content/30">
            <span>© {DateTime.utc_now().year} Innoso. {gettext("All rights reserved.")}</span>
            <div class="flex items-center gap-2">
              <a href="https://linkedin.com/company/innoso" target="_blank" rel="noopener" aria-label="LinkedIn"
                class="w-9 h-9 rounded-xl border border-black/[0.07] dark:border-white/[0.07] flex items-center justify-center text-base-content/30 hover:text-base-content hover:border-primary/35 transition-all duration-200">
                <svg viewBox="0 0 24 24" fill="currentColor" class="size-4" aria-hidden="true">
                  <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 01-2.063-2.065 2.064 2.064 0 112.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
                </svg>
              </a>
              <a href="https://github.com/innoso" target="_blank" rel="noopener" aria-label="GitHub"
                class="w-9 h-9 rounded-xl border border-black/[0.07] dark:border-white/[0.07] flex items-center justify-center text-base-content/30 hover:text-base-content hover:border-primary/35 transition-all duration-200">
                <svg viewBox="0 0 24 24" fill="currentColor" class="size-4" aria-hidden="true">
                  <path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/>
                </svg>
              </a>
              <a href="https://x.com/innoso" target="_blank" rel="noopener" aria-label="X / Twitter"
                class="w-9 h-9 rounded-xl border border-black/[0.07] dark:border-white/[0.07] flex items-center justify-center text-base-content/30 hover:text-base-content hover:border-primary/35 transition-all duration-200">
                <svg viewBox="0 0 24 24" fill="currentColor" class="size-4" aria-hidden="true">
                  <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-4.714-6.231-5.401 6.231H2.744l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                </svg>
              </a>
            </div>
            <span class="flex items-center gap-1.5">
              {gettext("Built with")} <span class="text-red-400">♥</span> {gettext("by passionate developers")}
            </span>
          </div>
        </div>
      </footer>

      <%!-- Floating WhatsApp --%>
      <a href="https://wa.me/252XXXXXXXXX" target="_blank" rel="noopener" aria-label={gettext("Chat on WhatsApp")}
        class="fixed bottom-6 right-6 z-50 w-14 h-14 rounded-full bg-emerald-500 text-white flex items-center justify-center shadow-xl shadow-emerald-500/35 hover:scale-110 hover:bg-emerald-400 transition-all duration-200">
        <svg viewBox="0 0 24 24" fill="currentColor" class="size-7" aria-hidden="true">
          <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
        </svg>
      </a>
    </div>
    """
  end

  @impl true
  def handle_event("filter_tag", %{"tag" => ""}, socket) do
    {:noreply, assign(socket, :filter_tag, nil)}
  end

  def handle_event("filter_tag", %{"tag" => tag}, socket) do
    {:noreply, assign(socket, :filter_tag, tag)}
  end

  def handle_event("toggle_menu", _params, socket) do
    {:noreply, assign(socket, :mobile_menu_open, !socket.assigns.mobile_menu_open)}
  end

  def handle_event("close_menu", _params, socket) do
    {:noreply, assign(socket, :mobile_menu_open, false)}
  end

  def handle_event("select_date", %{"date" => date_str}, socket) do
    date = Date.from_iso8601!(date_str)
    # clear selected slot if it belongs to a different date
    selected_slot =
      case socket.assigns.selected_slot do
        %{date: d} = slot when d == date -> slot
        _ -> nil
      end

    {:noreply,
     socket
     |> assign(:selected_date, date)
     |> assign(:selected_slot, selected_slot)}
  end

  def handle_event("select_slot", %{"date" => date_str, "time" => time_str}, socket) do
    date = Date.from_iso8601!(date_str)
    time = Time.from_iso8601!(time_str)
    {:noreply, assign(socket, :selected_slot, %{date: date, time: time})}
  end

  def handle_event("next_step", _params, socket) do
    {:noreply, assign(socket, :booking_step, :contact)}
  end

  def handle_event("prev_step", _params, socket) do
    {:noreply, assign(socket, :booking_step, :pick_slot)}
  end

  def handle_event("validate_booking", %{"booking" => params}, socket) do
    {:noreply, assign(socket, :booking_form, to_form(params, as: :booking))}
  end

  def handle_event("submit_booking", %{"booking" => params}, socket) do
    slot = socket.assigns.selected_slot

    attrs =
      Map.merge(params, %{
        "requested_date" => Date.to_string(slot.date),
        "requested_time" => Time.to_string(slot.time),
        "status" => "pending"
      })

    case Bookings.create_booking(attrs) do
      {:ok, booking} ->
        Innoso.Bookings.BookingNotifier.deliver_confirmation(booking)
        {:noreply, assign(socket, :booking_step, :success)}

      {:error, changeset} ->
        {:noreply, assign(socket, :booking_form, to_form(changeset, as: :booking))}
    end
  end

  def handle_event("reset_booking", _params, socket) do
    slots = Scheduling.available_slots_for_weeks(3)

    {:noreply,
     socket
     |> assign(:booking_step, :pick_slot)
     |> assign(:selected_slot, nil)
     |> assign(:selected_date, first_available_date(slots))
     |> assign(:booking_form, to_form(%{}, as: :booking))
     |> assign(:slots, slots)}
  end

  defp first_available_date(slots) do
    slots
    |> Enum.reject(& &1.taken)
    |> Enum.map(& &1.date)
    |> Enum.uniq()
    |> Enum.sort(Date)
    |> List.first()
  end

  defp dates_with_counts(slots) do
    slots
    |> Enum.group_by(& &1.date)
    |> Enum.map(fn {date, date_slots} ->
      {date, Enum.count(date_slots, &(!&1.taken))}
    end)
    |> Enum.sort_by(&elem(&1, 0), Date)
  end

  defp slots_for_date(slots, date) do
    slots
    |> Enum.filter(&(Date.compare(&1.date, date) == :eq))
    |> Enum.sort_by(& &1.time, Time)
  end

  defp format_time(%Time{hour: h, minute: m}) do
    period = if h >= 12, do: "PM", else: "AM"
    display_hour = if h > 12, do: h - 12, else: if(h == 0, do: 12, else: h)
    "#{display_hour}:#{String.pad_leading(Integer.to_string(m), 2, "0")} #{period}"
  end

  defp format_time(_), do: ""
end
