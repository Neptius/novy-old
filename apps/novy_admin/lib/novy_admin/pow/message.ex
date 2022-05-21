defmodule NovyAdmin.Pow.Messages do
  use Pow.Phoenix.Messages

  use Pow.Extension.Phoenix.Messages,
    extensions: [PowAssent]

  import NovyAdmin.Gettext

  def user_not_authenticated(_conn), do: gettext("Vous devez être connecté pour voir cette page.")

  def invalid_credentials(_conn), do: gettext("REKT.")

  def pow_assent_signed_in(conn) do
    provider = Phoenix.Naming.humanize(conn.params["provider"])

    gettext("You've been signed in with %{provider}.", provider: provider)
  end

  def pow_assent_login_with_provider(conn) do
    provider = Phoenix.Naming.humanize(conn.params["provider"])

    gettext("Connexion via %{provider}", provider: provider)
  end

  def pow_assent_remove_provider_authentication(conn) do
    provider = Phoenix.Naming.humanize(conn.params["provider"])

    gettext("Déconnexion de %{provider}", provider: provider)
  end
end
