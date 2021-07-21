defmodule NovyAdmin.AuthController do
  use NovyAdmin, :controller
  alias NovyAdmin.UserAuth
  alias NovyData.AuthService

  def callback(conn, params) do
    case AuthService.start_auth(params, NovyAdmin.Endpoint.url()) do
      {:ok, user_id, _auth_user_id} ->
        conn
        |> UserAuth.log_in_user(user_id)

      {:error, error} ->
        conn
        |> UserAuth.log_in_fail(error)
    end
  end

  def delete(conn, _params) do
    conn
    |> UserAuth.log_out_user()
  end
end
