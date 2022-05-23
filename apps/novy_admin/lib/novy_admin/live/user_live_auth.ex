defmodule NovyAdmin.UserLiveAuth do
  @moduledoc false

  import Phoenix.LiveView

  alias Pow.Store.CredentialsCache
  alias Pow.Phoenix.Routes

  def on_mount(:default, _params, _session, socket) do
    {:cont, socket}
  end

  def on_mount(:user, _params, session, socket) do
    socket = assign_new(socket, :current_user, fn -> get_current_user(socket, session) end)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: Routes.after_sign_out_path(%Plug.Conn{}))}
    end
  end

  defp get_current_user(socket, session, config \\ [otp_app: :tasklist])

  defp get_current_user(socket, %{"novy_admin_auth" => signed_token}, config) do
    conn = struct!(Plug.Conn, secret_key_base: socket.endpoint.config(:secret_key_base))
    salt = Atom.to_string(Pow.Plug.Session)

    with {:ok, token} <- Pow.Plug.verify_token(conn, salt, signed_token, config),
         # Use Pow.Store.Backend.EtsCache if you haven't configured Mnesia yet.
         {user, _metadata} <-
           CredentialsCache.get([backend: Pow.Store.Backend.EtsCache], token) do
      user
    else
      _ -> nil
    end
  end

  defp get_current_user(_, _, _), do: nil
end
