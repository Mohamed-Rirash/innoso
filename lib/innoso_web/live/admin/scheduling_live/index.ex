defmodule InnosoWeb.Admin.SchedulingLive.Index do
  use InnosoWeb, :live_view

  alias Innoso.Scheduling

  @all_days ~w(monday tuesday wednesday thursday friday saturday sunday)

  @impl true
  def mount(_params, _session, socket) do
    {:ok, config} = Scheduling.get_or_create_config()

    {:ok,
     socket
     |> assign(:config, config)
     |> assign(:all_days, @all_days)
     |> assign(:selected_days, config.available_days)
     |> assign(:form, to_form(Scheduling.change_config(config)))
     |> assign(:page_title, "Scheduling — Admin")}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply, assign(socket, :current_path, URI.parse(url).path)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_scope={@current_scope} current_path={@current_path}>
      <div class="p-8 max-w-2xl">
        <div class="mb-8">
          <h1 class="text-2xl font-bold">Scheduling Settings</h1>
          <p class="text-base-content/60 mt-1 text-sm">
            Configure the available booking slots shown to visitors.
          </p>
        </div>

        <div class="card bg-base-100 shadow border border-base-300">
          <div class="card-body space-y-6">
            <.form for={@form} phx-submit="save" phx-change="validate">

              <%!-- Hours row --%>
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-semibold mb-1.5">Start Hour</label>
                  <select
                    name={@form[:start_hour].name}
                    id={@form[:start_hour].id}
                    class="select select-bordered w-full text-sm"
                  >
                    <option :for={h <- 0..22} value={h} selected={@form[:start_hour].value == h or to_string(@form[:start_hour].value) == to_string(h)}>
                      {format_hour(h)}
                    </option>
                  </select>
                  <p :if={@form[:start_hour].errors != []} class="text-error text-xs mt-1">
                    {hd(@form[:start_hour].errors) |> elem(0)}
                  </p>
                </div>
                <div>
                  <label class="block text-sm font-semibold mb-1.5">End Hour</label>
                  <select
                    name={@form[:end_hour].name}
                    id={@form[:end_hour].id}
                    class="select select-bordered w-full text-sm"
                  >
                    <option :for={h <- 1..24} value={h} selected={@form[:end_hour].value == h or to_string(@form[:end_hour].value) == to_string(h)}>
                      {format_hour(h)}
                    </option>
                  </select>
                  <p :if={@form[:end_hour].errors != []} class="text-error text-xs mt-1">
                    {hd(@form[:end_hour].errors) |> elem(0)}
                  </p>
                </div>
              </div>

              <%!-- Slot duration --%>
              <div>
                <label class="block text-sm font-semibold mb-1.5">Slot Duration</label>
                <select
                  name={@form[:slot_minutes].name}
                  id={@form[:slot_minutes].id}
                  class="select select-bordered w-full text-sm"
                >
                  <option :for={m <- [30, 45, 60, 90, 120]} value={m} selected={@form[:slot_minutes].value == m or to_string(@form[:slot_minutes].value) == to_string(m)}>
                    {m} minutes
                  </option>
                </select>
              </div>

              <%!-- Available days --%>
              <div>
                <label class="block text-sm font-semibold mb-3">Available Days</label>
                <div class="flex flex-wrap gap-2">
                  <button
                    :for={day <- @all_days}
                    type="button"
                    phx-click="toggle_day"
                    phx-value-day={day}
                    class={[
                      "px-4 py-2 rounded-xl text-sm font-bold border transition-all",
                      day in @selected_days &&
                        "bg-primary text-white border-primary shadow-sm",
                      day not in @selected_days &&
                        "border-base-300 text-base-content/50 hover:border-primary/50 hover:text-primary"
                    ]}
                  >
                    {String.capitalize(day)}
                  </button>
                </div>
                <%!-- Hidden inputs so selected days travel with form submit --%>
                <input :for={day <- @selected_days} type="hidden" name="config[available_days][]" value={day} />
                <p :if={@selected_days == []} class="text-error text-xs mt-2">At least one day must be selected.</p>
              </div>

              <div class="pt-2 border-t border-base-300 flex items-center gap-3">
                <.button class="btn btn-primary" phx-disable-with="Saving...">
                  Save Settings
                </.button>
                <p class="text-xs text-base-content/40">
                  Changes take effect immediately for new bookings.
                </p>
              </div>
            </.form>
          </div>
        </div>

        <%!-- Preview --%>
        <div class="mt-6 card bg-base-100 border border-base-300 shadow">
          <div class="card-body p-5">
            <h3 class="font-bold text-sm mb-3">Current Schedule Preview</h3>
            <div class="text-sm text-base-content/60 space-y-1">
              <p>
                <span class="font-medium text-base-content">Days:</span>
                {Enum.map(@selected_days, &String.capitalize/1) |> Enum.join(", ")}
              </p>
              <p>
                <span class="font-medium text-base-content">Hours:</span>
                {format_hour(@config.start_hour)} – {format_hour(@config.end_hour)}
              </p>
              <p>
                <span class="font-medium text-base-content">Slot size:</span>
                {@config.slot_minutes} minutes
              </p>
            </div>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end

  @impl true
  def handle_event("toggle_day", %{"day" => day}, socket) do
    days = socket.assigns.selected_days

    updated =
      if day in days,
        do: List.delete(days, day),
        else: days ++ [day]

    {:noreply, assign(socket, :selected_days, updated)}
  end

  def handle_event("validate", %{"config" => params}, socket) do
    params = Map.put(params, "available_days", socket.assigns.selected_days)
    changeset = Scheduling.change_config(socket.assigns.config, params)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"config" => params}, socket) do
    params = Map.put(params, "available_days", socket.assigns.selected_days)

    case Scheduling.update_config(socket.assigns.config, params) do
      {:ok, config} ->
        {:noreply,
         socket
         |> assign(:config, config)
         |> assign(:selected_days, config.available_days)
         |> assign(:form, to_form(Scheduling.change_config(config)))
         |> put_flash(:info, "Scheduling settings saved")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp format_hour(h) when is_integer(h) do
    period = if h >= 12, do: "PM", else: "AM"
    display = cond do
      h == 0 -> 12
      h > 12 -> h - 12
      h == 24 -> 12
      true -> h
    end
    "#{display}:00 #{period}"
  end

  defp format_hour(h), do: format_hour(String.to_integer(to_string(h)))
end
