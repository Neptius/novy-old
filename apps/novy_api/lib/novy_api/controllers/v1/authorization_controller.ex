defmodule NovyApi.V1.AuthorizationController do
  use NovyApi, :controller

  alias Plug.Conn
  alias PowAssent.Plug

  @spec new(Conn.t(), map()) :: Conn.t()
  def new(conn, %{"provider" => provider}) do
    conn
    |> Plug.authorize_url(provider, redirect_uri(conn))
    |> case do
      {:ok, url, conn} ->
        json(conn, %{data: %{url: url, session_params: conn.private[:pow_assent_session_params]}})

      {:error, _error, conn} ->
        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: "An unexpected error occurred"}})
    end
  end

  defp redirect_uri(conn) do
    "http://localhost:4002/api/v1/auth/#{conn.params["provider"]}/callback"
  end

  @spec callback(Conn.t(), map()) :: Conn.t()
  def callback(conn, %{"provider" => provider} = params) do
    session_params = Map.fetch!(params, "session_params")
    params = Map.drop(params, ["provider", "session_params"])

    conn
    |> Conn.put_private(:pow_assent_session_params, session_params)
    |> Plug.callback_upsert(provider, params, redirect_uri(conn))
    |> case do
      {:ok, conn} ->
        json(conn, %{
          data: %{
            access_token: conn.private.api_access_token,
            renewal_token: conn.private.api_renewal_token
          }
        })

      {:error, conn} ->
        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: "An unexpected error occurred"}})
    end
  end
end
