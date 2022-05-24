defmodule NovyApi.Router do
  use NovyApi, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug NovyApi.APIAuthPlug, otp_app: :novy_api
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: NovyApi.APIAuthErrorHandler
  end

  scope "/api/v1", NovyApi.V1, as: :api_v1 do
    pipe_through :api

    resources "/registration", RegistrationController, singleton: true, only: [:create]
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew
    get "/auth/:provider/new", AuthorizationController, :new
    post "/auth/:provider/callback", AuthorizationController, :callback
  end

  scope "/api/v1", NovyApi.V1, as: :api_v1 do
    pipe_through [:api, :api_protected]

    # Your protected API endpoints here
  end
end
