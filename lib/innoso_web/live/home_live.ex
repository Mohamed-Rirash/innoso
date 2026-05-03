defmodule InnosoWeb.HomeLive do
  use InnosoWeb, :live_view

  alias Innoso.Portfolio
  alias Innoso.Team
  alias Innoso.Bookings
  alias Innoso.Scheduling

  @services [
    %{icon: "hero-code-bracket", title: "Custom Web Applications", desc: "Tailor-made web solutions built to solve your unique business challenges and scale with your growth."},
    %{icon: "hero-device-phone-mobile", title: "Mobile Apps", desc: "Native and cross-platform mobile applications that deliver seamless experiences on iOS and Android."},
    %{icon: "hero-building-office-2", title: "Business & Government Systems", desc: "Robust, secure platforms for enterprises and public-sector organizations that demand reliability."},
    %{icon: "hero-shopping-cart", title: "E-commerce Solutions", desc: "Complete online stores with payments, inventory, and analytics to grow your sales online."},
    %{icon: "hero-globe-alt", title: "Landing Pages & Portfolios", desc: "High-converting, beautifully designed pages that represent your brand and attract customers."},
    %{icon: "hero-chart-bar-square", title: "Dashboard & Admin Panels", desc: "Intuitive control centers that give you real-time insight and control over your operations."},
    %{icon: "hero-light-bulb", title: "Tech Consulting", desc: "Strategic guidance to help your business overcome challenges and unlock growth through technology."}
  ]

  @steps [
    %{number: "01", title: "Discover", desc: "We listen deeply to understand your vision, goals, and constraints before writing a single line of code."},
    %{number: "02", title: "Build", desc: "Our team designs and develops your solution using modern technology with continuous feedback loops."},
    %{number: "03", title: "Launch", desc: "We deploy, test, and hand over a polished product — then stay available for ongoing support."}
  ]

  @impl true
  def mount(_params, _session, socket) do
    slots = if connected?(socket), do: Scheduling.available_slots_for_weeks(3), else: []

    {:ok,
     socket
     |> assign(:projects, Portfolio.list_projects())
     |> assign(:members, Team.list_members())
     |> assign(:slots, slots)
     |> assign(:services, @services)
     |> assign(:steps, @steps)
     |> assign(:booking_step, :pick_slot)
     |> assign(:selected_slot, nil)
     |> assign(:booking_form, to_form(%{}, as: :booking))
     |> assign(:page_title, "Innoso — Modern Tech Solutions")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100">
      <!-- Navbar -->
      <nav class="navbar sticky top-0 z-50 bg-base-100/90 backdrop-blur border-b border-base-300 px-4 sm:px-8">
        <div class="flex-1">
          <a href="/" class="flex items-center gap-2">
            <div class="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
              <span class="text-primary-content font-bold">I</span>
            </div>
            <span class="font-bold text-xl">Innoso</span>
          </a>
        </div>
        <div class="flex-none gap-4">
          <ul class="hidden md:flex items-center gap-1 text-sm">
            <li><a href="#about" class="btn btn-ghost btn-sm">About</a></li>
            <li><a href="#services" class="btn btn-ghost btn-sm">Services</a></li>
            <li><a href="#projects" class="btn btn-ghost btn-sm">Projects</a></li>
            <li><a href="#team" class="btn btn-ghost btn-sm">Team</a></li>
          </ul>
          <div class="flex items-center gap-2">
            <!-- Language switcher -->
            <div class="dropdown dropdown-end">
              <div tabindex="0" role="button" class="btn btn-ghost btn-sm gap-1">
                <.icon name="hero-language" class="size-4" />
                <span class="hidden sm:inline">EN</span>
              </div>
              <ul tabindex="0" class="dropdown-content menu bg-base-100 rounded-box z-10 w-36 p-2 shadow border border-base-300">
                <li><.link href={~p"/locale/en"}>English</.link></li>
                <li><.link href={~p"/locale/ar"}>العربية</.link></li>
                <li><.link href={~p"/locale/so"}>Soomaali</.link></li>
                <li><.link href={~p"/locale/fr"}>Français</.link></li>
              </ul>
            </div>
            <Layouts.theme_toggle />
            <a href="#booking" class="btn btn-primary btn-sm">Book a Call</a>
          </div>
        </div>
      </nav>

      <!-- Hero -->
      <section class="relative overflow-hidden px-4 sm:px-8 pt-20 pb-28">
        <div class="absolute inset-0 bg-gradient-to-br from-primary/5 via-base-100 to-secondary/5 pointer-events-none" />
        <div class="max-w-4xl mx-auto text-center relative">
          <div class="inline-flex items-center gap-2 bg-primary/10 text-primary rounded-full px-4 py-1.5 text-sm font-medium mb-6">
            <span class="w-2 h-2 bg-primary rounded-full animate-pulse"></span>
            Youth-Powered Tech Innovation
          </div>
          <h1 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight leading-tight mb-6">
            We Build Technology <br />
            <span class="text-primary">That Moves Businesses</span>
          </h1>
          <p class="text-lg sm:text-xl text-base-content/70 max-w-2xl mx-auto mb-10">
            Innoso is a collective of passionate young developers creating software solutions for businesses, governments, organizations, and individuals — from web apps to enterprise systems.
          </p>
          <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <a href="#booking" class="btn btn-primary btn-lg">
              Book a Free Consultation
              <.icon name="hero-arrow-right" class="size-5" />
            </a>
            <a href="#projects" class="btn btn-ghost btn-lg">See Our Work</a>
          </div>
        </div>
      </section>

      <!-- About / Mission & Vision -->
      <section id="about" class="px-4 sm:px-8 py-20 bg-base-200">
        <div class="max-w-5xl mx-auto">
          <div class="text-center mb-12">
            <h2 class="text-3xl sm:text-4xl font-bold mb-4">Who We Are</h2>
            <p class="text-base-content/60 max-w-xl mx-auto">A group of talented young developers united by one mission: making technology accessible and impactful.</p>
          </div>
          <div class="grid md:grid-cols-2 gap-8">
            <div class="card bg-base-100 shadow-lg">
              <div class="card-body">
                <div class="w-12 h-12 bg-primary/10 rounded-xl flex items-center justify-center mb-4">
                  <.icon name="hero-rocket-launch" class="size-6 text-primary" />
                </div>
                <h3 class="text-xl font-bold mb-2">Our Mission</h3>
                <p class="text-base-content/70">
                  To empower businesses, governments, and individuals by delivering high-quality, modern software solutions that solve real problems — built with craftsmanship, delivered with care.
                </p>
              </div>
            </div>
            <div class="card bg-base-100 shadow-lg">
              <div class="card-body">
                <div class="w-12 h-12 bg-secondary/10 rounded-xl flex items-center justify-center mb-4">
                  <.icon name="hero-eye" class="size-6 text-secondary" />
                </div>
                <h3 class="text-xl font-bold mb-2">Our Vision</h3>
                <p class="text-base-content/70">
                  To become the most trusted tech partner in our region — where clients choose us not just for our code, but for our commitment to their success and our ability to grow with them.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Services -->
      <section id="services" class="px-4 sm:px-8 py-20">
        <div class="max-w-6xl mx-auto">
          <div class="text-center mb-12">
            <h2 class="text-3xl sm:text-4xl font-bold mb-4">What We Build</h2>
            <p class="text-base-content/60 max-w-xl mx-auto">From idea to launch — we cover every layer of your digital needs.</p>
          </div>
          <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <div :for={service <- @services} class="card bg-base-100 border border-base-300 hover:border-primary hover:shadow-lg transition-all duration-200">
              <div class="card-body">
                <div class="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center mb-3">
                  <.icon name={service.icon} class="size-5 text-primary" />
                </div>
                <h3 class="font-bold text-lg"><%= service.title %></h3>
                <p class="text-base-content/60 text-sm mt-1"><%= service.desc %></p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- How We Work -->
      <section class="px-4 sm:px-8 py-20 bg-base-200">
        <div class="max-w-4xl mx-auto">
          <div class="text-center mb-12">
            <h2 class="text-3xl sm:text-4xl font-bold mb-4">How We Work</h2>
            <p class="text-base-content/60 max-w-xl mx-auto">A simple, transparent process designed to get you from idea to reality — fast.</p>
          </div>
          <div class="grid md:grid-cols-3 gap-8">
            <div :for={step <- @steps} class="text-center">
              <div class="w-16 h-16 bg-primary rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg shadow-primary/20">
                <span class="text-primary-content font-bold text-lg"><%= step.number %></span>
              </div>
              <h3 class="text-xl font-bold mb-2"><%= step.title %></h3>
              <p class="text-base-content/60 text-sm"><%= step.desc %></p>
            </div>
          </div>
        </div>
      </section>

      <!-- Projects -->
      <section id="projects" class="px-4 sm:px-8 py-20">
        <div class="max-w-6xl mx-auto">
          <div class="text-center mb-12">
            <h2 class="text-3xl sm:text-4xl font-bold mb-4">Our Work</h2>
            <p class="text-base-content/60 max-w-xl mx-auto">Real solutions delivered for real clients. Explore what we've built.</p>
          </div>

          <div :if={@projects == []} class="text-center py-16 text-base-content/40">
            <.icon name="hero-briefcase" class="size-12 mx-auto mb-3" />
            <p>Projects coming soon — check back shortly.</p>
          </div>

          <div :if={@projects != []} class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <div :for={project <- @projects} class="card bg-base-100 shadow-md hover:shadow-xl transition-shadow">
              <figure :if={project.cover_image} class="h-48 overflow-hidden">
                <img src={project.cover_image} alt={project.name} class="w-full h-full object-cover" />
              </figure>
              <div :if={!project.cover_image} class="h-48 bg-base-200 flex items-center justify-center">
                <.icon name="hero-briefcase" class="size-10 text-base-content/20" />
              </div>
              <div class="card-body">
                <div class="flex items-start justify-between gap-2">
                  <h3 class="card-title text-base"><%= project.name %></h3>
                  <span class="badge badge-outline badge-sm shrink-0"><%= project.client_type %></span>
                </div>
                <p class="text-sm text-base-content/60 line-clamp-2"><%= project.description %></p>
                <div :if={project.tags} class="flex flex-wrap gap-1 mt-1">
                  <span :for={tag <- String.split(project.tags || "", ",")} class="badge badge-ghost badge-xs"><%= String.trim(tag) %></span>
                </div>
                <div class="card-actions mt-2">
                  <a :if={project.live_url} href={project.live_url} target="_blank" class="btn btn-primary btn-sm">
                    View Live <.icon name="hero-arrow-top-right-on-square" class="size-3" />
                  </a>
                  <div :if={project.demo_username} class="text-xs text-base-content/50 self-center">
                    Demo: <%= project.demo_username %> / <%= project.demo_password %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Team -->
      <section id="team" class="px-4 sm:px-8 py-20 bg-base-200">
        <div class="max-w-5xl mx-auto">
          <div class="text-center mb-12">
            <h2 class="text-3xl sm:text-4xl font-bold mb-4">Meet the Team</h2>
            <p class="text-base-content/60 max-w-xl mx-auto">The talented developers behind every line of code.</p>
          </div>

          <div :if={@members == []} class="text-center py-12 text-base-content/40">
            <.icon name="hero-users" class="size-12 mx-auto mb-3" />
            <p>Team profiles coming soon.</p>
          </div>

          <div :if={@members != []} class="grid sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
            <div :for={member <- @members} class="card bg-base-100 shadow text-center">
              <div class="card-body items-center pt-6">
                <div class="avatar mb-3">
                  <div class="w-20 h-20 rounded-full bg-base-200">
                    <img :if={member.photo} src={member.photo} alt={member.name} class="rounded-full" />
                    <div :if={!member.photo} class="flex items-center justify-center h-full rounded-full">
                      <.icon name="hero-user" class="size-8 text-base-content/30" />
                    </div>
                  </div>
                </div>
                <h3 class="font-bold"><%= member.name %></h3>
                <p class="text-sm text-base-content/60"><%= member.role %></p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Booking -->
      <section id="booking" class="px-4 sm:px-8 py-20">
        <div class="max-w-2xl mx-auto">
          <div class="text-center mb-10">
            <h2 class="text-3xl sm:text-4xl font-bold mb-4">Book a Free Consultation</h2>
            <p class="text-base-content/60">Tell us about your project and pick a time. We'll reach out to confirm your meeting.</p>
          </div>

          <div class="card bg-base-100 shadow-xl border border-base-300">
            <div class="card-body">
              <!-- Step: Pick Slot -->
              <div :if={@booking_step == :pick_slot}>
                <h3 class="font-semibold text-lg mb-4">Choose a time slot</h3>
                <div :if={@slots == []} class="text-center py-8 text-base-content/40">
                  <.icon name="hero-calendar" class="size-10 mx-auto mb-2" />
                  <p>Loading available slots...</p>
                </div>
                <div :if={@slots != []} class="grid grid-cols-2 sm:grid-cols-3 gap-2">
                  <button
                    :for={slot <- @slots}
                    disabled={slot.taken}
                    phx-click="select_slot"
                    phx-value-date={Date.to_string(slot.date)}
                    phx-value-time={Time.to_string(slot.time)}
                    class={[
                      "btn btn-sm font-normal flex-col h-auto py-2 gap-0",
                      slot.taken && "btn-disabled opacity-40",
                      !slot.taken && @selected_slot && Date.to_string(@selected_slot.date) == Date.to_string(slot.date) && Time.to_string(@selected_slot.time) == Time.to_string(slot.time) && "btn-primary",
                      !slot.taken && !(@selected_slot && Date.to_string(@selected_slot.date) == Date.to_string(slot.date) && Time.to_string(@selected_slot.time) == Time.to_string(slot.time)) && "btn-outline"
                    ]}
                  >
                    <span class="text-xs font-medium"><%= Calendar.strftime(slot.date, "%b %d") %></span>
                    <span class="text-xs"><%= format_time(slot.time) %></span>
                  </button>
                </div>
                <div class="mt-4">
                  <button disabled={is_nil(@selected_slot)} phx-click="next_step"
                    class="btn btn-primary w-full">
                    Continue
                    <.icon name="hero-arrow-right" class="size-4" />
                  </button>
                </div>
              </div>

              <!-- Step: Contact Info -->
              <div :if={@booking_step == :contact}>
                <div class="flex items-center gap-3 mb-4">
                  <button phx-click="prev_step" class="btn btn-ghost btn-sm btn-circle">
                    <.icon name="hero-arrow-left" class="size-4" />
                  </button>
                  <div>
                    <h3 class="font-semibold text-lg">Your details</h3>
                    <p class="text-xs text-base-content/60">
                      Selected: <%= if @selected_slot, do: Calendar.strftime(@selected_slot.date, "%B %d") <> " at " <> format_time(@selected_slot.time) %>
                    </p>
                  </div>
                </div>

                <.form for={@booking_form} phx-submit="submit_booking" phx-change="validate_booking">
                  <div class="space-y-3">
                    <.input field={@booking_form[:name]} type="text" label="Full Name" required />
                    <.input field={@booking_form[:email]} type="email" label="Email Address" required />
                    <.input field={@booking_form[:phone]} type="tel" label="Phone Number" required />
                    <.input field={@booking_form[:description]} type="textarea" label="What do you need help with?" required />
                    <.button class="btn btn-primary w-full" phx-disable-with="Booking...">
                      Book Meeting
                      <.icon name="hero-calendar-days" class="size-4" />
                    </.button>
                  </div>
                </.form>
              </div>

              <!-- Step: Success -->
              <div :if={@booking_step == :success} class="text-center py-8">
                <div class="w-16 h-16 bg-success/10 rounded-full flex items-center justify-center mx-auto mb-4">
                  <.icon name="hero-check-circle" class="size-10 text-success" />
                </div>
                <h3 class="text-xl font-bold mb-2">Meeting Requested!</h3>
                <p class="text-base-content/60 mb-6">
                  We've received your booking request. Check your email for a confirmation — we'll be in touch shortly.
                </p>
                <button phx-click="reset_booking" class="btn btn-outline btn-sm">
                  Book Another Meeting
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Footer -->
      <footer class="bg-base-300 px-4 sm:px-8 py-12">
        <div class="max-w-5xl mx-auto">
          <div class="grid sm:grid-cols-3 gap-8 mb-8">
            <div>
              <div class="flex items-center gap-2 mb-3">
                <div class="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                  <span class="text-primary-content font-bold">I</span>
                </div>
                <span class="font-bold text-lg">Innoso</span>
              </div>
              <p class="text-sm text-base-content/60">Youth-powered software solutions for businesses, governments, and individuals.</p>
            </div>
            <div>
              <h4 class="font-semibold mb-3">Services</h4>
              <ul class="space-y-1 text-sm text-base-content/60">
                <li>Web Applications</li>
                <li>Mobile Apps</li>
                <li>E-commerce</li>
                <li>Tech Consulting</li>
              </ul>
            </div>
            <div>
              <h4 class="font-semibold mb-3">Contact</h4>
              <ul class="space-y-1 text-sm text-base-content/60">
                <li>codesavvylabs@gmail.com</li>
                <li><a href="#booking" class="link link-primary">Book a meeting</a></li>
              </ul>
            </div>
          </div>
          <div class="border-t border-base-content/10 pt-6 text-center text-sm text-base-content/40">
            © <%= DateTime.utc_now().year %> Innoso. All rights reserved.
          </div>
        </div>
      </footer>
    </div>
    """
  end

  @impl true
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
    form = to_form(params, as: :booking)
    {:noreply, assign(socket, :booking_form, form)}
  end

  def handle_event("submit_booking", %{"booking" => params}, socket) do
    slot = socket.assigns.selected_slot
    attrs = Map.merge(params, %{
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
     |> assign(:booking_form, to_form(%{}, as: :booking))
     |> assign(:slots, slots)}
  end

  defp format_time(%Time{hour: h, minute: m}) do
    period = if h >= 12, do: "PM", else: "AM"
    display_hour = if h > 12, do: h - 12, else: (if h == 0, do: 12, else: h)
    "#{display_hour}:#{String.pad_leading(Integer.to_string(m), 2, "0")} #{period}"
  end
  defp format_time(_), do: ""
end
