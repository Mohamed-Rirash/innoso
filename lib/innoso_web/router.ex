defmodule InnosoWeb.Router do
  use InnosoWeb, :router

  import InnosoWeb.AdminAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {InnosoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin_panel do
  end

  # Public routes
  scope "/", InnosoWeb do
    pipe_through :browser

    live "/", HomeLive
    get "/locale/:locale", LocaleController, :set
  end

  # Admin auth routes (unauthenticated only)
  scope "/admin", InnosoWeb do
    pipe_through [:browser, :redirect_if_admin_is_authenticated]

    get "/login", AdminSessionController, :new
    get "/login/:token", AdminSessionController, :confirm
    post "/login", AdminSessionController, :create
  end

  # Admin logout (any auth state)
  scope "/admin", InnosoWeb do
    pipe_through :browser

    delete "/logout", AdminSessionController, :delete
  end

  # Admin panel (requires authentication)
  scope "/admin", InnosoWeb do
    pipe_through [:browser, :require_authenticated_admin, :admin_panel]

    get "/", Admin.DashboardController, :index
    get "/settings", AdminSettingsController, :edit
    put "/settings", AdminSettingsController, :update
    get "/settings/confirm-email/:token", AdminSettingsController, :confirm_email

    live "/projects", Admin.ProjectLive.Index, :index
    live "/projects/new", Admin.ProjectLive.Index, :new
    live "/projects/:id/edit", Admin.ProjectLive.Index, :edit

    live "/team", Admin.MemberLive.Index, :index
    live "/team/new", Admin.MemberLive.Index, :new
    live "/team/:id/edit", Admin.MemberLive.Index, :edit

    live "/bookings", Admin.BookingLive.Index, :index
    live "/bookings/:id", Admin.BookingLive.Show, :show

    live "/admins", Admin.AdminUserLive.Index, :index
    live "/admins/new", Admin.AdminUserLive.Index, :new
  end

  if Application.compile_env(:innoso, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: InnosoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
