defmodule InnosoWeb.Admin.BookingLive.Index do
  use InnosoWeb, :live_view

  alias Innoso.Bookings

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin flash={@flash} current_scope={@current_scope}>
      <div class="p-8">
        <div class="mb-6">
          <h1 class="text-2xl font-bold">Bookings</h1>
          <p class="text-base-content/60 text-sm mt-1">Meeting requests from potential clients</p>
        </div>

        <div :if={@bookings == []} class="card bg-base-100 shadow">
          <div class="card-body items-center text-center py-16">
            <.icon name="hero-calendar-days" class="size-12 text-base-content/30" />
            <p class="text-base-content/60 mt-2">No booking requests yet.</p>
          </div>
        </div>

        <div :if={@bookings != []} class="card bg-base-100 shadow overflow-hidden">
          <div class="overflow-x-auto">
            <table class="table table-zebra">
              <thead>
                <tr>
                  <th>Client</th>
                  <th>Date & Time</th>
                  <th>Status</th>
                  <th class="text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={booking <- @bookings} id={"booking-#{booking.id}"}>
                  <td>
                    <div class="font-medium"><%= booking.name %></div>
                    <div class="text-xs text-base-content/60"><%= booking.email %></div>
                    <div class="text-xs text-base-content/60"><%= booking.phone %></div>
                  </td>
                  <td>
                    <div class="font-medium"><%= Calendar.strftime(booking.requested_date, "%B %d, %Y") %></div>
                    <div class="text-sm text-base-content/60"><%= format_time(booking.requested_time) %></div>
                  </td>
                  <td>
                    <span class={[
                      "badge badge-sm",
                      booking.status == "pending" && "badge-warning",
                      booking.status == "confirmed" && "badge-success",
                      booking.status == "cancelled" && "badge-error"
                    ]}>
                      <%= booking.status %>
                    </span>
                  </td>
                  <td class="text-right">
                    <div class="flex gap-2 justify-end">
                      <.link navigate={~p"/admin/bookings/#{booking.id}"} class="btn btn-ghost btn-xs">
                        View
                      </.link>
                      <button :if={booking.status == "pending"} phx-click="confirm" phx-value-id={booking.id}
                        class="btn btn-success btn-xs">
                        Confirm
                      </button>
                      <button :if={booking.status != "cancelled"} phx-click="cancel" phx-value-id={booking.id}
                        data-confirm="Cancel this booking?" class="btn btn-ghost btn-xs text-error">
                        Cancel
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </Layouts.admin>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :bookings, Bookings.list_bookings())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Bookings")}
  end

  @impl true
  def handle_event("confirm", %{"id" => id}, socket) do
    booking = Bookings.get_booking!(id)
    {:ok, _} = Bookings.confirm_booking(booking)
    {:noreply, socket |> put_flash(:info, "Booking confirmed") |> assign(:bookings, Bookings.list_bookings())}
  end

  def handle_event("cancel", %{"id" => id}, socket) do
    booking = Bookings.get_booking!(id)
    {:ok, _} = Bookings.cancel_booking(booking)
    {:noreply, socket |> put_flash(:info, "Booking cancelled") |> assign(:bookings, Bookings.list_bookings())}
  end

  defp format_time(%Time{hour: h, minute: m}) do
    period = if h >= 12, do: "PM", else: "AM"
    display_hour = if h > 12, do: h - 12, else: (if h == 0, do: 12, else: h)
    "#{display_hour}:#{String.pad_leading(Integer.to_string(m), 2, "0")} #{period}"
  end
  defp format_time(_), do: ""
end
