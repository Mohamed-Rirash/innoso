defmodule InnosoWeb.BlogLive.Index do
  use InnosoWeb, :live_view

  alias Innoso.Blog

  @impl true
  def mount(_params, _session, socket) do
    posts = Blog.list_published_posts()

    {:ok,
     socket
     |> assign(:posts, posts)
     |> assign(:page_title, "Blog — Innoso")
     |> assign(:page_description, "Insights, tutorials, and updates from the Innoso team.")}
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
            navigate={~p"/"}
            class="flex items-center gap-2 shrink-0 text-sm font-semibold text-base-content/55 hover:text-base-content transition-colors group"
          >
            <div class="w-8 h-8 rounded-xl bg-white/60 dark:bg-white/[0.07] backdrop-blur-sm border border-black/[0.07] dark:border-white/[0.10] flex items-center justify-center group-hover:border-primary/40 transition-colors">
              <.icon name="hero-arrow-left" class="size-4 group-hover:-translate-x-0.5 transition-transform" />
            </div>
            <span class="hidden sm:inline">{gettext("Home")}</span>
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

      <%!-- Hero --%>
      <section class="px-4 sm:px-6 lg:px-8 pt-16 pb-12">
        <div class="max-w-7xl mx-auto text-center">
          <span class="inline-block text-xs font-bold text-primary uppercase tracking-widest bg-primary/10 dark:bg-primary/15 border border-primary/20 dark:border-primary/25 px-4 py-1.5 rounded-full mb-5">
            {gettext("Insights")}
          </span>
          <h1 class="text-5xl sm:text-6xl font-black tracking-tight mb-5">
            {gettext("The Innoso")}
            <span class="bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
              {gettext("Blog")}
            </span>
          </h1>
          <p class="text-base-content/50 text-xl max-w-xl mx-auto leading-relaxed">
            {gettext("Thoughts on software, technology, and building great products.")}
          </p>
        </div>
      </section>

      <%!-- Posts grid --%>
      <section class="px-4 sm:px-6 lg:px-8 pb-24">
        <div class="max-w-7xl mx-auto">

          <%!-- Empty state --%>
          <div :if={@posts == []} class="text-center py-24">
            <div class="w-20 h-20 rounded-2xl bg-white dark:bg-base-200 border border-black/[0.08] dark:border-white/[0.07] flex items-center justify-center mx-auto mb-5">
              <.icon name="hero-pencil-square" class="size-10 text-base-content/25" />
            </div>
            <p class="text-base-content/40 font-semibold text-lg">{gettext("No posts yet")}</p>
            <p class="text-base-content/28 text-sm mt-1">{gettext("Check back soon — we're writing.")}</p>
          </div>

          <div :if={@posts != []} class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
            <.link
              :for={post <- @posts}
              navigate={~p"/blog/#{post.slug}"}
              class="group flex flex-col rounded-2xl border border-black/[0.08] dark:border-white/[0.07] bg-white dark:bg-base-200 overflow-hidden transition-all duration-300 hover:-translate-y-2 relative"
            >
              <%!-- Cover --%>
              <div class="relative h-48 overflow-hidden shrink-0">
                <img
                  :if={post.cover_image}
                  src={post.cover_image}
                  alt={post.title}
                  class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <div
                  :if={!post.cover_image}
                  class="w-full h-full bg-gradient-to-br from-primary/12 via-primary/4 to-secondary/12 flex items-center justify-center"
                >
                  <.icon name="hero-pencil-square" class="size-10 text-primary/20" />
                </div>
                <div class="absolute inset-0 bg-gradient-to-t from-black/50 via-black/10 to-transparent"></div>
                <div class="absolute top-3 right-3 w-8 h-8 rounded-xl bg-black/50 backdrop-blur-sm border border-white/15 flex items-center justify-center opacity-0 group-hover:opacity-100 translate-y-1 group-hover:translate-y-0 transition-all duration-200">
                  <.icon name="hero-arrow-up-right" class="size-4 text-white" />
                </div>
              </div>

              <%!-- Body --%>
              <div class="flex flex-col flex-1 p-5 relative">
                <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-primary opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                <div class="absolute -bottom-4 left-1/2 -translate-x-1/2 w-1/2 h-12 bg-primary/40 blur-2xl opacity-0 group-hover:opacity-80 transition-all duration-500 pointer-events-none"></div>

                <div class="flex items-center gap-3 text-xs text-base-content/40 font-medium mb-3">
                  <span :if={post.published_at}>
                    {Calendar.strftime(post.published_at, "%b %d, %Y")}
                  </span>
                  <span class="w-1 h-1 rounded-full bg-base-content/20"></span>
                  <span>{Blog.read_time(post)} min read</span>
                </div>

                <h2 class="font-black text-lg leading-snug mb-2 group-hover:text-primary transition-colors duration-200">
                  {post.title}
                </h2>
                <p class="text-sm text-base-content/55 line-clamp-3 leading-relaxed flex-1">
                  {post.excerpt || InnosoWeb.Markdown.plain_text(post.body) |> String.slice(0, 160)}
                </p>

                <div class="flex items-center gap-1.5 mt-4 pt-4 border-t border-black/[0.06] dark:border-white/[0.08] text-sm font-bold text-primary">
                  {gettext("Read more")}
                  <.icon name="hero-arrow-right" class="size-3.5 group-hover:translate-x-0.5 transition-transform" />
                </div>
              </div>
            </.link>
          </div>
        </div>
      </section>
    </div>
    """
  end
end
