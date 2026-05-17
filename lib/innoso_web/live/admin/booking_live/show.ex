defmodule InnosoWeb.Admin.BookingLive.Show do
  use InnosoWeb, :live_view

  alias Innoso.Bookings

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_scope={@current_scope}>
      <div class="p-8 max-w-2xl">
        <div class="flex items-center gap-4 mb-6">
          <.link navigate={~p"/admin/bookings"} class="btn btn-ghost btn-sm">
            <.icon name="hero-arrow-left" class="size-4" /> Back
          </.link>
          <h1 class="text-2xl font-bold">Booking Details</h1>
        </div>

        <div class="card bg-base-100 shadow">
          <div class="card-body space-y-4">
            <div class="flex items-center justify-between">
              <h2 class="text-lg font-semibold">{@booking.name}</h2>
              <span class={[
                "badge",
                @booking.status == "pending" && "badge-warning",
                @booking.status == "confirmed" && "badge-success",
                @booking.status == "cancelled" && "badge-error"
              ]}>
                {@booking.status}
              </span>
            </div>

            <div class="divider my-0" />

            <div class="grid grid-cols-2 gap-4">
              <div>
                <p class="text-xs text-base-content/60 uppercase tracking-wide">Email</p>
                <p class="font-medium mt-1">{@booking.email}</p>
              </div>
              <div>
                <p class="text-xs text-base-content/60 uppercase tracking-wide">Phone</p>
                <p class="font-medium mt-1">{@booking.phone}</p>
              </div>
              <div>
                <p class="text-xs text-base-content/60 uppercase tracking-wide">Requested Date</p>
                <p class="font-medium mt-1">
                  {Calendar.strftime(@booking.requested_date, "%B %d, %Y")}
                </p>
              </div>
              <div>
                <p class="text-xs text-base-content/60 uppercase tracking-wide">Requested Time</p>
                <p class="font-medium mt-1">{format_time(@booking.requested_time)}</p>
              </div>
            </div>

            <div>
              <p class="text-xs text-base-content/60 uppercase tracking-wide mb-1">What they need</p>
              <p class="text-sm bg-base-200 rounded-lg p-3">{@booking.description}</p>
            </div>

            <div :if={@booking.status != "cancelled"} class="flex gap-3 pt-2">
              <button :if={@booking.status == "pending"} phx-click="confirm" class="btn btn-success">
                <.icon name="hero-check" class="size-4" /> Confirm Booking
              </button>
              <button
                phx-click="cancel"
                data-confirm="Cancel this booking?"
                class="btn btn-error btn-soft"
              >
                Cancel Booking
              </button>
            </div>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    booking = Bookings.get_booking!(id)
    {:ok, assign(socket, booking: booking, page_title: "Booking — #{booking.name}")}
  end

  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  @impl true
  def handle_event("confirm", _params, socket) do
    {:ok, booking} = Bookings.confirm_booking(socket.assigns.booking)
    {:noreply, socket |> put_flash(:info, "Booking confirmed") |> assign(:booking, booking)}
  end

  def handle_event("cancel", _params, socket) do
    {:ok, booking} = Bookings.cancel_booking(socket.assigns.booking)
    {:noreply, socket |> put_flash(:info, "Booking cancelled") |> assign(:booking, booking)}
  end

  defp format_time(%Time{hour: h, minute: m}) do
    period = if h >= 12, do: "PM", else: "AM"
    display_hour = if h > 12, do: h - 12, else: if(h == 0, do: 12, else: h)
    "#{display_hour}:#{String.pad_leading(Integer.to_string(m), 2, "0")} #{period}"
  end

  defp format_time(_), do: ""
end
