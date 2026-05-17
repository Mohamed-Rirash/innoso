defmodule Innoso.Bookings.BookingNotifier do
  import Swoosh.Email

  alias Innoso.Mailer

  def deliver_confirmation(booking) do
    email =
      new()
      |> to({booking.name, booking.email})
      |> from({"Innoso", "noreply@innoso.com"})
      |> subject("Your meeting request is received — Innoso")
      |> text_body("""
      Hi #{booking.name},

      Thank you for reaching out to Innoso!

      We've received your meeting request for:
        Date: #{Calendar.strftime(booking.requested_date, "%B %d, %Y")}
        Time: #{format_time(booking.requested_time)}

      What you shared:
        #{booking.description}

      We'll review your request and get back to you shortly to confirm the meeting.

      In the meantime, feel free to reply to this email if you have any questions.

      Best regards,
      The Innoso Team
      codesavvylabs@gmail.com
      """)

    Mailer.deliver(email)
  end

  defp format_time(%Time{hour: h, minute: m}) do
    period = if h >= 12, do: "PM", else: "AM"
    display_hour = if h > 12, do: h - 12, else: if(h == 0, do: 12, else: h)
    "#{display_hour}:#{String.pad_leading(Integer.to_string(m), 2, "0")} #{period}"
  end

  defp format_time(_), do: ""
end
