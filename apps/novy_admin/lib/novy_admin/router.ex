defmodule NovyAdmin.Router do
  use NovyAdmin, :router
  use Pow.Phoenix.Router
  use PowAssent.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {NovyAdmin.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :skip_csrf_protection do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  scope "/" do
    pipe_through [:browser]
    live "/", NovyAdmin.HomeLive.Index, :index

    # * ACTIVE L'INSCRIPTION
    # pow_routes()
    # * OR
    #! DESACTIVE L'INSCRIPTION
    pow_session_routes()

    # * ACTIVE L'INSCRIPTION
    # pow_assent_routes()
    # * OR
    #! DESACTIVE L'INSCRIPTION
    pow_assent_authorization_routes()
  end

  #! DESACTIVE L'INSCRIPTION
  scope "/", Pow.Phoenix, as: "pow" do
    pipe_through [:browser, :protected]

    resources "/registration", RegistrationController,
      singleton: true,
      only: [:edit, :update, :delete]
  end

  scope "/" do
    pipe_through :skip_csrf_protection

    pow_assent_authorization_post_callback_routes()
  end

  scope "/", NovyAdmin do
    pipe_through [:browser, :protected]

    # Add your protected routes here
  end

  live_session :default do
    scope "/", NovyAdmin do
      pipe_through [:browser, :protected]

      live "/page-1", Page1Live.Index, :index
      live "/page-2", Page2Live.Index, :index
      live "/page-3", Page3Live.Index, :index
      live "/page-4", Page4Live.Index, :index
      live "/page-5", Page5Live.Index, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", NovyAdmin do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NovyAdmin.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
