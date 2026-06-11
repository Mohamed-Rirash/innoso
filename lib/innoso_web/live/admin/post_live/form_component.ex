defmodule InnosoWeb.Admin.PostLive.FormComponent do
  use InnosoWeb, :live_component

  alias Innoso.Blog
  alias Innoso.Blog.Post

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>{@title}</.header>

      <.form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-4 mt-4"
      >
        <.input field={@form[:title]} type="text" label="Title" required phx-debounce="500" />
        <.input field={@form[:slug]} type="text" label="Slug (URL)" placeholder="my-post-title" required />

        <%!-- Body with preview tab --%>
        <div>
          <div class="flex items-center justify-between mb-1.5">
            <label class="block text-sm font-semibold leading-6 text-base-content">
              Body <span class="text-error ml-0.5">*</span>
            </label>
            <div class="flex items-center gap-0.5 p-0.5 rounded-lg bg-black/[0.04] dark:bg-white/[0.06] border border-black/[0.07] dark:border-white/[0.08]">
              <button
                type="button"
                phx-click="switch_tab"
                phx-value-tab="write"
                phx-target={@myself}
                class={[
                  "flex items-center gap-1.5 text-xs font-bold px-3 py-1.5 rounded-md transition-all",
                  @body_tab == :write && "bg-white dark:bg-base-100 shadow-sm text-base-content",
                  @body_tab != :write && "text-base-content/45 hover:text-base-content"
                ]}
              >
                <.icon name="hero-pencil" class="size-3" /> Write
              </button>
              <button
                type="button"
                phx-click="switch_tab"
                phx-value-tab="preview"
                phx-target={@myself}
                class={[
                  "flex items-center gap-1.5 text-xs font-bold px-3 py-1.5 rounded-md transition-all",
                  @body_tab == :preview && "bg-white dark:bg-base-100 shadow-sm text-base-content",
                  @body_tab != :preview && "text-base-content/45 hover:text-base-content"
                ]}
              >
                <.icon name="hero-eye" class="size-3" /> Preview
              </button>
            </div>
          </div>
          <div class={[@body_tab == :preview && "hidden"]}>
            <.input field={@form[:body]} type="textarea" label="" rows="14" required />
          </div>
          <div :if={@body_tab == :preview}>
            <div class={[
              "min-h-[300px] rounded-xl border border-black/[0.08] dark:border-white/[0.08]",
              "bg-white dark:bg-base-300 px-4 py-3 text-sm text-base-content/70 md-content",
              @body_preview == "" && "flex items-center justify-center text-base-content/30 italic"
            ]}>
              <%= if @body_preview == "" do %>
                Nothing to preview yet.
              <% else %>
                <%= Phoenix.HTML.raw(@body_preview) %>
              <% end %>
            </div>
            <input type="hidden" name={@form[:body].name} value={@form[:body].value} />
          </div>
          <p class="text-[11px] text-base-content/38 mt-1.5 flex items-center gap-1">
            <.icon name="hero-information-circle" class="size-3.5 shrink-0" />
            Supports Markdown
          </p>
        </div>

        <.input field={@form[:excerpt]} type="textarea" label="Excerpt (optional)" rows="3"
          placeholder="Short summary shown in listing. Auto-generated from body if left blank." />
        <.input field={@form[:cover_image]} type="text" label="Cover Image URL" placeholder="https://..." />
        <%!-- Publish date + time (separate inputs for clarity) --%>
        <div>
          <p class="text-sm font-semibold leading-6 text-base-content mb-1.5">
            Publish At
            <span class="text-xs font-normal text-base-content/40 ml-1">— leave blank to save as draft</span>
          </p>
          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="text-[11px] font-bold text-base-content/45 uppercase tracking-wide mb-1 block">Date</label>
              <input
                type="date"
                name="pub_date"
                value={@pub_date}
                class="input input-bordered w-full text-sm rounded-xl"
              />
            </div>
            <div>
              <label class="text-[11px] font-bold text-base-content/45 uppercase tracking-wide mb-1 block">Time</label>
              <input
                type="time"
                name="pub_time"
                value={@pub_time}
                class="input input-bordered w-full text-sm rounded-xl"
              />
            </div>
          </div>
          <p class="text-[11px] text-base-content/38 mt-1.5 flex items-center gap-1">
            <.icon name="hero-information-circle" class="size-3.5 shrink-0" />
            Times are stored in UTC. Leave date blank to keep as draft.
          </p>
        </div>

        <.button class="btn btn-primary w-full" phx-disable-with="Saving...">Save Post</.button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    {pub_date, pub_time} = split_datetime(post.published_at)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:pub_date, pub_date)
     |> assign(:pub_time, pub_time)
     |> assign_new(:body_tab, fn -> :write end)
     |> assign_new(:body_preview, fn -> "" end)
     |> assign_new(:form, fn -> to_form(Blog.change_post(post)) end)}
  end

  @impl true
  def handle_event("validate", params, socket) do
    post_params = Map.get(params, "post", %{})
    pub_date = Map.get(params, "pub_date", socket.assigns.pub_date)
    pub_time = Map.get(params, "pub_time", socket.assigns.pub_time)

    post_params = maybe_autofill_slug(post_params, socket)
    changeset = Blog.change_post(socket.assigns.post, post_params)

    {:noreply,
     socket
     |> assign(:pub_date, pub_date)
     |> assign(:pub_time, pub_time)
     |> assign(:form, to_form(changeset, action: :validate))}
  end

  def handle_event("save", params, socket) do
    post_params = Map.get(params, "post", %{})
    pub_date = Map.get(params, "pub_date", "")
    pub_time = Map.get(params, "pub_time", "")

    post_params =
      post_params
      |> maybe_autofill_slug(socket)
      |> Map.put("published_at", combine_datetime(pub_date, pub_time))

    save_post(socket, socket.assigns.action, post_params)
  end

  def handle_event("switch_tab", %{"tab" => "preview"}, socket) do
    body = socket.assigns.form[:body].value || ""
    html = InnosoWeb.Markdown.render(body)
    {:noreply, socket |> assign(:body_tab, :preview) |> assign(:body_preview, html)}
  end

  def handle_event("switch_tab", %{"tab" => "write"}, socket) do
    {:noreply, assign(socket, :body_tab, :write)}
  end

  defp maybe_autofill_slug(%{"title" => title, "slug" => ""} = params, _socket) do
    Map.put(params, "slug", Post.slugify(title))
  end

  defp maybe_autofill_slug(params, _socket), do: params

  defp split_datetime(nil), do: {"", "09:00"}
  defp split_datetime(%DateTime{} = dt) do
    {Calendar.strftime(dt, "%Y-%m-%d"), Calendar.strftime(dt, "%H:%M")}
  end
  defp split_datetime(_), do: {"", "09:00"}

  defp combine_datetime("", _), do: nil
  defp combine_datetime(date, time) do
    t = if time == "", do: "00:00", else: time
    case NaiveDateTime.from_iso8601("#{date}T#{t}:00") do
      {:ok, ndt} -> DateTime.from_naive!(ndt, "Etc/UTC")
      _ -> nil
    end
  end

  defp save_post(socket, :edit, params) do
    case Blog.update_post(socket.assigns.post, params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated")
         |> push_navigate(to: ~p"/admin/blog")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_post(socket, :new, params) do
    case Blog.create_post(params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created")
         |> push_navigate(to: ~p"/admin/blog")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
