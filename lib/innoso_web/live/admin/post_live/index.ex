defmodule InnosoWeb.Admin.PostLive.Index do
  use InnosoWeb, :live_view

  alias Innoso.Blog
  alias Innoso.Blog.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:posts, Blog.list_all_posts())
     |> assign(:page_title, "Blog — Admin")}
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply,
     socket
     |> assign(:current_path, URI.parse(url).path)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket |> assign(:post, nil) |> assign(:page_title, "Blog — Admin")
  end

  defp apply_action(socket, :new, _params) do
    socket |> assign(:post, %Post{}) |> assign(:page_title, "New Post — Admin")
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket |> assign(:post, Blog.get_post!(id)) |> assign(:page_title, "Edit Post — Admin")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_scope={@current_scope} current_path={@current_path}>
      <div class="p-8">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold">Blog</h1>
            <p class="text-base-content/60 mt-0.5 text-sm">{length(@posts)} posts</p>
          </div>
          <.link navigate={~p"/admin/blog/new"} class="btn btn-primary btn-sm rounded-lg gap-1.5">
            <.icon name="hero-plus" class="size-4" /> New Post
          </.link>
        </div>

        <div :if={@posts == []} class="card bg-base-100 border border-base-300 shadow-sm">
          <div class="card-body text-center py-16 text-base-content/40">
            <.icon name="hero-pencil-square" class="size-12 mx-auto mb-3 opacity-30" />
            <p class="font-semibold">No posts yet</p>
            <p class="text-sm">Create your first blog post to get started.</p>
          </div>
        </div>

        <div :if={@posts != []} class="card bg-base-100 border border-base-300 shadow-sm">
          <div class="overflow-x-auto">
            <table class="table table-sm">
              <thead>
                <tr class="text-xs text-base-content/50 uppercase tracking-wide border-b border-base-300">
                  <th class="font-semibold">Title</th>
                  <th class="font-semibold">Slug</th>
                  <th class="font-semibold">Status</th>
                  <th class="font-semibold">Published</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr :for={post <- @posts} class="border-b border-base-200 last:border-0 hover:bg-base-200/50">
                  <td class="font-semibold max-w-xs truncate">{post.title}</td>
                  <td class="font-mono text-xs text-base-content/50">{post.slug}</td>
                  <td>
                    <span class={[
                      "badge badge-sm",
                      Blog.published?(post) && "badge-success",
                      !Blog.published?(post) && "badge-ghost"
                    ]}>
                      {if Blog.published?(post), do: "Published", else: "Draft"}
                    </span>
                  </td>
                  <td class="text-xs text-base-content/50">
                    {if post.published_at, do: Calendar.strftime(post.published_at, "%b %d, %Y"), else: "—"}
                  </td>
                  <td>
                    <div class="flex items-center gap-1 justify-end">
                      <.link
                        :if={Blog.published?(post)}
                        navigate={~p"/blog/#{post.slug}"}
                        target="_blank"
                        class="btn btn-ghost btn-xs gap-1"
                      >
                        <.icon name="hero-arrow-top-right-on-square" class="size-3.5" />
                      </.link>
                      <.link navigate={~p"/admin/blog/#{post.id}/edit"} class="btn btn-ghost btn-xs gap-1">
                        <.icon name="hero-pencil" class="size-3.5" /> Edit
                      </.link>
                      <button
                        phx-click="delete"
                        phx-value-id={post.id}
                        data-confirm={"Delete \"#{post.title}\"?"}
                        class="btn btn-ghost btn-xs text-error hover:bg-error/10"
                      >
                        <.icon name="hero-trash" class="size-3.5" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <.modal :if={@live_action in [:new, :edit]} id="post-modal" show on_cancel={JS.navigate(~p"/admin/blog")}>
        <.live_component
          module={InnosoWeb.Admin.PostLive.FormComponent}
          id={(@post && @post.id) || :new}
          title={if @live_action == :new, do: "New Post", else: "Edit Post"}
          action={@live_action}
          post={@post}
        />
      </.modal>
    </Layouts.admin>
    """
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Blog.get_post!(id)
    {:ok, _} = Blog.delete_post(post)
    {:noreply, socket |> assign(:posts, Blog.list_all_posts()) |> put_flash(:info, "Post deleted")}
  end
end
