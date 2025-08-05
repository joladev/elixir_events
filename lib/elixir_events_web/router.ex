defmodule ElixirEventsWeb.Router do
  use ElixirEventsWeb, :router

  import ElixirEventsWeb.UserAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ElixirEventsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  if Application.compile_env(:elixir_events, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard",
        metrics: ElixirEventsWeb.Telemetry,
        ecto_repos: [ElixirEvents.Repo]

      forward "/flags", FunWithFlags.UI.Router, namespace: "dev/flags"
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  else
    scope "/dev" do
      pipe_through [:browser, :require_authenticated_user]

      live_dashboard "/dashboard",
        metrics: ElixirEventsWeb.Telemetry,
        ecto_repos: [ElixirEvents.Repo]

      forward "/flags", FunWithFlags.UI.Router, namespace: "dev/flags"
    end
  end

  ## Authentication routes

  scope "/", ElixirEventsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ElixirEventsWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/log_in", Live.UserLogin, :new
    end

    post "/users/log_in", Controllers.UserSession, :create
  end

  scope "/", ElixirEventsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ElixirEventsWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", Live.UserSettings, :edit
      live "/users/settings/confirm_email/:token", Live.UserSettings, :confirm_email
      live "/admin", Live.Admin, :admin
    end
  end

  scope "/", ElixirEventsWeb do
    pipe_through [:browser]

    delete "/users/log_out", Controllers.UserSession, :delete

    live_session :current_user,
      on_mount: [{ElixirEventsWeb.UserAuth, :mount_current_user}] do
      live "/", Live.Page, :show
      live "/propose", Live.Propose, :propose
      live "/events/:event_id/:date", Live.Event, :event
    end
  end
end
