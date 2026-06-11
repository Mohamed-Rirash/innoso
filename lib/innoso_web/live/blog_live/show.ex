defmodule InnosoWeb.BlogLive.Show do
  use InnosoWeb, :live_view

  alias Innoso.Blog

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    post = Blog.get_published_post_by_slug!(slug)

    {:ok,
     socket
     |> assign(:post, post)
     |> assign(:body_html, InnosoWeb.Markdown.render(post.body))
     |> assign(:read_time, Blog.read_time(post))
     |> assign(:page_title, post.title <> " — Innoso Blog")
     |> assign(:page_description, post.excerpt || InnosoWeb.Markdown.plain_text(post.body) |> String.slice(0, 160))
     |> assign(:og_image, post.cover_image)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100 antialiased overflow-x-hidden">
      <div aria-hidden="true" class="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
        <div class="absolute -top-[400px] -left-[200px] w-[900px] h-[900px] rounded-full bg-violet-600/8 dark:bg-violet-500/20 blur-[160px]"></div>
        <div class="absolute top-[30%] -right-[300px] w-[800px] h-[800px] rounded-full bg-indigo-500/6 dark:bg-blue-500/16 blur-[150px]"></div>
      </div>

      <%!-- Navbar --%>
      <nav class="sticky top-0 z-50 bg-white/75 dark:bg-black/35 backdrop-blur-2xl border-b border-black/[0.07] dark:border-white/[0.08] px-4 sm:px-6 lg:px-8">
        <div class="max-w-7xl mx-auto h-16 flex items-center gap-4">
          <.link
            navigate={~p"/blog"}
            class="flex items-center gap-2 shrink-0 text-sm font-semibold text-base-content/55 hover:text-base-content transition-colors group"
          >
            <div class="w-8 h-8 rounded-xl bg-white/60 dark:bg-white/[0.07] backdrop-blur-sm border border-black/[0.07] dark:border-white/[0.10] flex items-center justify-center group-hover:border-primary/40 transition-colors">
              <.icon name="hero-arrow-left" class="size-4 group-hover:-translate-x-0.5 transition-transform" />
            </div>
            <span class="hidden sm:inline">{gettext("Blog")}</span>
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

      <%!-- Cover image --%>
      <div :if={@post.cover_image} class="relative h-[50vh] min-h-72 overflow-hidden">
        <img src={@post.cover_image} alt={@post.title} class="w-full h-full object-cover" />
        <div class="absolute inset-0 bg-gradient-to-t from-base-100 via-base-100/20 to-transparent"></div>
      </div>

      <%!-- Article --%>
      <article class="px-4 sm:px-6 lg:px-8 py-14">
        <div class="max-w-3xl mx-auto">
          <%!-- Meta --%>
          <div class="flex items-center gap-3 text-xs text-base-content/40 font-medium mb-6">
            <span class="inline-flex items-center gap-1.5 text-xs font-black text-primary uppercase tracking-widest bg-primary/10 dark:bg-primary/15 border border-primary/20 dark:border-primary/25 px-3 py-1.5 rounded-full">
              {gettext("Blog")}
            </span>
            <span :if={@post.published_at}>
              {Calendar.strftime(@post.published_at, "%B %d, %Y")}
            </span>
            <span class="w-1 h-1 rounded-full bg-base-content/20"></span>
            <span>{@read_time} {gettext("min read")}</span>
          </div>

          <%!-- Title --%>
          <h1 class="text-4xl sm:text-5xl font-black tracking-tight leading-[1.1] mb-6">
            {@post.title}
          </h1>

          <%!-- Excerpt lead --%>
          <p :if={@post.excerpt} class="text-xl text-base-content/60 leading-relaxed mb-10 pb-10 border-b border-black/[0.08] dark:border-white/[0.07]">
            {@post.excerpt}
          </p>

          <%!-- Body --%>
          <div class="md-content prose-lg text-base-content/70 leading-relaxed">
            <%= Phoenix.HTML.raw(@body_html) %>
          </div>

          <%!-- Author strip --%>
          <div class="mt-14 pt-8 border-t border-black/[0.08] dark:border-white/[0.07] flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-lg shadow-primary/25">
              <span class="text-white font-black text-sm select-none">IN</span>
            </div>
            <div>
              <p class="font-black text-base">Innoso Team</p>
              <p class="text-sm text-base-content/45">{gettext("Building software that matters")}</p>
            </div>
          </div>

          <%!-- CTA --%>
          <div class="mt-10 p-6 rounded-2xl border border-primary/20 dark:border-primary/30 bg-primary/5 dark:bg-primary/8">
            <p class="font-black text-base mb-1">{gettext("Found this useful?")}</p>
            <p class="text-sm text-base-content/55 mb-4 leading-relaxed">
              {gettext("We help businesses build great software. Book a free call and let's talk about your project.")}
            </p>
            <a
              href="/#booking"
              class="inline-flex items-center gap-2 btn btn-sm rounded-xl font-bold bg-gradient-to-r from-primary to-secondary text-white border-0 shadow-lg shadow-primary/25 hover:opacity-90 transition-all"
            >
              {gettext("Book a Free Call")}
              <.icon name="hero-arrow-right" class="size-3.5" />
            </a>
          </div>
        </div>
      </article>
    </div>
    """
  end
end
