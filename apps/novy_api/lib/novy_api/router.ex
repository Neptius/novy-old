defmodule NovyApi.Router do
  use NovyApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", NovyApi do
    pipe_through :api
  end
end
