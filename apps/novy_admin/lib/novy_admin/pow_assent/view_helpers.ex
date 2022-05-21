defmodule NovyAdmin.PowAssent.ViewHelpers do
  @moduledoc false

  alias Phoenix.{HTML.Tag}
  alias PowAssent.Phoenix.AuthorizationController
  alias FontAwesome

  def authorization_link(conn, provider) do
    query_params = invitation_token_query_params(conn) ++ request_path_query_params(conn)

    msg =
      AuthorizationController.extension_messages(conn).login_with_provider(%{
        conn
        | params: %{"provider" => provider}
      })

    path =
      AuthorizationController.routes(conn).path_for(
        conn,
        AuthorizationController,
        :new,
        [provider],
        query_params
      )

    provider_str = Atom.to_string(provider)

    Tag.content_tag :a, href: path, class: "btn-" <> provider_str <> "-login" do
      [
        FontAwesome.icon(provider_str, type: "brands"),
        Tag.content_tag(:span, msg)
      ]
    end
  end

  defp invitation_token_query_params(%{assigns: %{invited_user: %{invitation_token: token}}}),
    do: [invitation_token: token]

  defp invitation_token_query_params(_conn), do: []

  defp request_path_query_params(%{assigns: %{request_path: request_path}}),
    do: [request_path: request_path]

  defp request_path_query_params(_conn), do: []
end
