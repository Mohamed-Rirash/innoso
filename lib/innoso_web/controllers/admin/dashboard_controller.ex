defmodule InnosoWeb.Admin.DashboardController do
  use InnosoWeb, :controller

  alias Innoso.Portfolio
  alias Innoso.Team
  alias Innoso.Bookings
  alias Innoso.Accounts

  def index(conn, _params) do
    stats = %{
      projects: length(Portfolio.list_projects()),
      members: length(Team.list_members()),
      pending_bookings: length(Bookings.list_pending_bookings()),
      total_bookings: length(Bookings.list_bookings()),
      admins: length(Accounts.list_admins())
    }

    render(conn, :index, stats: stats)
  end
end
