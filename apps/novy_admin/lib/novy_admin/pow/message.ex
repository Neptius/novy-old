defmodule NovyAdmin.Pow.Messages do
  @moduledoc false

  use Pow.Phoenix.Messages

  use Pow.Extension.Phoenix.Messages,
    extensions: [PowAssent]

  import NovyAdmin.Gettext

  def user_not_authenticated(_conn), do: gettext("Vous devez être connecté afin de consulter cette page.")

  # The provided login details did not work. Please verify your credentials, and try again.
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
