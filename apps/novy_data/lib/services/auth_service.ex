defmodule NovyData.AuthService do
  @moduledoc false

  use HTTPoison.Base

  alias NovyData.Randomizer
  alias NovyData.Accounts.{AuthProvider, AuthProviderSession, AuthUser, User}

  @doc false
  def init_auth(label, redirect_host) do
    with %AuthProvider{} = auth_provider <-
           AuthProvider.get_one_auth_provider(%{"label" => label}),
         state <- Randomizer.randomizer(32),
         {:ok, %AuthProviderSession{}} <-
           AuthProviderSession.create_auth_provider_session(%{
             state: state,
             auth_provider_id: auth_provider.id,
             type: "login"
           }),
         {:ok, url} <- format_auth_url(auth_provider, state, redirect_host) do
      {:ok, url}
    else
      {:error, error} ->
        {:error, error}

      _ ->
        {:error, "Provider invalide ou non configuré"}
    end
  end

  @doc false
  defp format_auth_url(%{:method => "oauth2"} = auth_provider, state, redirect_host) do
    query =
      URI.encode_query(%{
        "client_id" => auth_provider.client_id,
        "redirect_uri" => "#{redirect_host}/login_return?provider=#{auth_provider.label}",
        "response_type" => auth_provider.response_type,
        "state" => state,
        "scope" => auth_provider.scope,
        "force_verify" => true
      })

    {:ok, "#{auth_provider.authorize_url}?" <> query}
  end

  # @doc false
  # defp format_auth_url(%{:method => "openid"}, auth_params, state) do
  #   query =
  #     URI.encode_query(%{
  #       "openid.ns" => auth_params["openid.ns"],
  #       "openid.mode" => "checkid_setup",
  #       "openid.claimed_id" => auth_params["openid.claimed_id"],
  #       "openid.identity" => auth_params["openid.identity"],
  #       "openid.return_to" => auth_params["openid.return_to"],
  #       "state" => state
  #     })

  #   {:ok, "#{auth_params["login"]}?" <> query}
  # end

  @doc false
  defp format_auth_url(_auth_provider, _state, _redirect_host) do
    {:error, "Méthode Invalide"}
  end

  @doc false
  def init_link(label, redirect_host, user_id) do
    with %AuthProvider{} = auth_provider <-
           AuthProvider.get_one_auth_provider(%{"label" => label}),
         state <- Randomizer.randomizer(32),
         {:ok, %AuthProviderSession{}} <-
           AuthProviderSession.create_auth_provider_session(%{
             state: state,
             auth_provider_id: auth_provider.id,
             type: "link",
             user_id: user_id
           }),
         {:ok, url} <- format_link_url(auth_provider, state, redirect_host) do
      {:ok, url}
    else
      {:error, error} ->
        {:error, error}

      _ ->
        {:error, "Provider invalide ou non configuré"}
    end
  end

  @doc false
  defp format_link_url(%{:method => "oauth2"} = auth_provider, state, redirect_host) do
    query =
      URI.encode_query(%{
        "client_id" => auth_provider.client_id,
        "redirect_uri" => "#{redirect_host}/link_return?provider=#{auth_provider.label}",
        "response_type" => auth_provider.response_type,
        "state" => state,
        "scope" => auth_provider.scope,
        "force_verify" => true
      })

    {:ok, "#{auth_provider.authorize_url}?" <> query}
  end

  def start_auth(%{"error" => _state}) do
    {:error, "Erreur lors de l'authentification"}
  end

  @doc false
  def start_auth(%{"state" => _state, "provider" => _provider} = params, redirect_host) do
    with {:ok, %AuthProviderSession{} = auth_provider_session} <- verify_login_state(params),
         %AuthProvider{} = auth_provider <-
           AuthProvider.get_auth_provider(auth_provider_session.auth_provider_id),
         {:ok, authorization_params} <-
           verify_auth_user(auth_provider, params, redirect_host, "login_return"),
         {:ok, user_raw_data} <- fetch_user_data(auth_provider, authorization_params),
         {:ok, user_data} <- format_user_data(user_raw_data, auth_provider),
         exist_auth_user <-
           AuthUser.get_exist_auth_user(auth_provider.label, user_data["auth_provider_user_id"]),
         {:ok, user_id, auth_user_id} <-
           create_or_update_auth_user(exist_auth_user, user_data, auth_provider) do
      {:ok, user_id, auth_user_id}
    else
      {:error, error} ->
        {:error, error}

      _ ->
        {:error, "Erreur lors de l'authentification"}
    end
  end

  @doc false
  def start_link(%{"state" => _state, "provider" => _provider} = params, redirect_host, user_id) do
    with {:ok, %AuthProviderSession{} = auth_provider_session} <-
           verify_link_state(params, user_id),
         %AuthProvider{} = auth_provider <-
           AuthProvider.get_auth_provider(auth_provider_session.auth_provider_id),
         {:ok, authorization_params} <-
           verify_auth_user(auth_provider, params, redirect_host, "link_return"),
         {:ok, user_raw_data} <- fetch_user_data(auth_provider, authorization_params),
         {:ok, user_data} <- format_user_data(user_raw_data, auth_provider),
         exist_auth_user <-
           AuthUser.get_exist_auth_user(auth_provider.label, user_data["auth_provider_user_id"]),
         {:ok, user_id, auth_user_id} <-
           create_or_update_auth_user(exist_auth_user, user_data, auth_provider, user_id) do
      {:ok, user_id, auth_user_id}
    else
      {:error, error} ->
        {:error, error}

      _ ->
        {:error, "Erreur lors de l'authentification"}
    end
  end

  @doc false
  def verify_login_state(%{"state" => state, "provider" => provider}) do
    with %AuthProviderSession{verify: false} = auth_provider_session <-
           AuthProviderSession.get_one_auth_provider_login_state(
             state,
             provider
           ),
         {:ok, verified_auth_provider_session} <-
           AuthProviderSession.update_auth_provider_session(auth_provider_session, %{
             :verify => true
           }) do
      {:ok, verified_auth_provider_session}
    else
      {:error, error} ->
        {:error, error}

      _ ->
        {:error, "State ou Provider Invalide"}
    end
  end

  @doc false
  def verify_link_state(%{"state" => state, "provider" => provider}, user_id) do
    with %AuthProviderSession{verify: false} = auth_provider_session <-
           AuthProviderSession.get_one_auth_provider_link_state(
             state,
             provider,
             user_id
           ),
         {:ok, verified_auth_provider_session} <-
           AuthProviderSession.update_auth_provider_session(auth_provider_session, %{
             :verify => true
           }) do
      {:ok, verified_auth_provider_session}
    else
      {:error, error} ->
        {:error, error}

      _ ->
        {:error, "State ou Provider Invalide"}
    end
  end

  @doc false
  defp verify_auth_user(
         %AuthProvider{:method => "oauth2"} = auth_provider,
         %{"code" => code},
         redirect_host,
         return_type
       ) do
    request_body =
      URI.encode_query(%{
        "client_id" => auth_provider.client_id,
        "client_secret" => auth_provider.client_secret,
        "grant_type" => "authorization_code",
        "code" => code,
        "redirect_uri" => "#{redirect_host}/#{return_type}?provider=#{auth_provider.label}",
        "scope" => auth_provider.scope
      })

    options = %{
      "Content-Type" => "application/x-www-form-urlencoded"
    }

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(auth_provider.token_url, request_body, options),
         {:ok, decoded} <- Jason.decode(body) do
      {:ok, decoded}
    else
      res ->
        {:error, res}
    end
  end

  #   @doc false
  #   defp verify_auth_user(%{:method => "openid"}, params, %{"login" => url}) do
  #     query =
  #       params
  #       |> Enum.filter(fn {key, _value} -> String.starts_with?(Atom.to_string(key), "openid_") end)
  #       |> Enum.into(%{})
  #       |> Enum.reduce(
  #         %{},
  #         fn {key, value}, acc ->
  #           Map.put(acc, String.replace(Atom.to_string(key), "openid_", "openid."), value)
  #         end
  #       )
  #       |> Map.put("openid.mode", "check_authentication")
  #       |> URI.encode_query()

  #     case HTTPoison.get("#{url}?" <> query) do
  #       {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
  #         {:ok, String.contains?(body, "is_valid:true\n")}

  #       _ ->
  #         {:ok, false}
  #     end
  #   end

  #   @doc false
  #   defp verify_auth_user(_provider, _params, _auth_params) do
  #     {:error, "Méthode Invalide"}
  #   end

  @doc false
  defp fetch_user_data(
         %AuthProvider{:method => "oauth2", :user_url => url, :client_id => client_id},
         %{
           "access_token" => token
         }
       ) do
    headers = [
      Authorization: "Bearer #{token}",
      Accept: "Application/json; Charset=utf-8",
      "Client-ID": client_id
    ]

    options = [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 500]

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(url, headers, options),
         {:ok, decoded} <- Jason.decode(body) do
      {:ok, decoded}
    else
      error ->
        {:error, error}

      _ ->
        {:error, "Erreur: fetch_user_data oauth2"}
    end
  end

  #   @doc false
  #   defp get_user_data(
  #          %{"key" => key, "user" => user, "user_id" => user_id},
  #          %{:method => "openid"},
  #          true,
  #          %{:openid_claimed_id => claimed_id}
  #        ) do
  #     url =
  #       user
  #       |> String.replace("%ID%", String.replace(claimed_id, user_id, ""))
  #       |> String.replace("%KEY%", key)

  #     with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url),
  #          {:ok, decoded} <- Poison.decode(body) do
  #       {:ok, decoded}
  #     else
  #       error ->
  #         {:error, error}

  #       _ ->
  #         {:error, "Erreur: get_user_data openid"}
  #     end
  #   end

  # @doc false
  # defp get_user_data(_auth_provider, _params) do
  #   {:error, "Url utilisateur non valide"}
  # end

  #   @doc false
  defp format_user_data(user_raw_data, %AuthProvider{} = auth_provider) do
    user_path = auth_provider.user_path
    user_pseudo_path = auth_provider.user_pseudo_path
    user_id_path = auth_provider.user_id_path
    user_img_path = auth_provider.user_img_path
    user_img_url = auth_provider.user_img_url

    user_data =
      case user_path do
        user_path when user_path == nil or user_path == "" ->
          user_raw_data

        _ ->
          Elixpath.get!(user_raw_data, user_path)
      end

    auth_provider_user_img =
      case user_img_url do
        user_img_url when user_img_url == nil or user_img_url == "" ->
          user_data[user_img_path]

        _ ->
          user_img_url
          |> String.replace("{{ID}}", user_data[user_id_path])
          |> String.replace("{{AVATAR}}", user_data[user_img_path])
      end

    {
      :ok,
      %{
        "auth_provider_user_id" => user_data[user_id_path],
        "auth_provider_user_pseudo" => user_data[user_pseudo_path],
        "auth_provider_user_img" => auth_provider_user_img,
        "user_data" => user_data
      }
    }
  end

  defp create_or_update_auth_user(nil, auth_user_format_data, auth_provider) do
    auth_user_changeset = %AuthUser{
      :auth_provider_user_id => auth_user_format_data["auth_provider_user_id"],
      :auth_provider_user_pseudo => auth_user_format_data["auth_provider_user_pseudo"],
      :auth_provider_user_img => auth_user_format_data["auth_provider_user_img"],
      :user_data => auth_user_format_data["user_data"],
      :auth_provider_id => auth_provider.id
    }

    user_changeset = %{
      pseudo: auth_user_format_data["auth_provider_user_pseudo"]
    }

    case User.create_user_with_auth_user(user_changeset, auth_user_changeset) do
      {:ok, user} ->
        [auth_user] = user.auth_users
        {:ok, user.id, auth_user.id}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc false
  defp create_or_update_auth_user(exist_auth_user, auth_user_format_data, _auth_provider) do
    params = %{
      :user_data => auth_user_format_data["user_data"],
      :auth_provider_user_pseudo => auth_user_format_data["auth_provider_user_pseudo"],
      :auth_provider_user_img => auth_user_format_data["auth_provider_user_img"]
    }

    case AuthUser.update_auth_user(exist_auth_user, params) do
      {:ok, auth_user} ->
        {:ok, auth_user.user_id, auth_user.id}

      {:error, error} ->
        {:error, error}
    end
  end

  defp create_or_update_auth_user(nil, auth_user_format_data, auth_provider, user_id) do
    auth_user_changeset = %{
      :auth_provider_user_id => auth_user_format_data["auth_provider_user_id"],
      :auth_provider_user_pseudo => auth_user_format_data["auth_provider_user_pseudo"],
      :auth_provider_user_img => auth_user_format_data["auth_provider_user_img"],
      :user_data => auth_user_format_data["user_data"],
      :auth_provider_id => auth_provider.id,
      :user_id => user_id
    }

    case AuthUser.create_auth_user(auth_user_changeset) do
      {:ok, auth_user} ->
        {:ok, auth_user.user_id, auth_user.id}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc false
  defp create_or_update_auth_user(
         exist_auth_user,
         auth_user_format_data,
         _auth_provider,
         _user_id
       ) do
    params = %{
      :user_data => auth_user_format_data["user_data"],
      :auth_provider_user_pseudo => auth_user_format_data["auth_provider_user_pseudo"],
      :auth_provider_user_img => auth_user_format_data["auth_provider_user_img"]
    }

    case AuthUser.update_auth_user(exist_auth_user, params) do
      {:ok, auth_user} ->
        {:ok, auth_user.user_id, auth_user.id}

      {:error, error} ->
        {:error, error}
    end
  end

  #   def create_session(user, auth_provider_session) do
  #     {:ok, token, _claims} =
  #       NovyApiWeb.Guardian.encode_and_sign(user, %{}, token_type: :access, ttl: {7, :minutes})

  #     {:ok, refresh_token, _claims} =
  #       NovyApiWeb.Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {30, :minutes})

  #     auth_provider_session_changeset =
  #       auth_provider_session
  #       |> Repo.preload([:user])
  #       |> AuthProviderSession.change_one(%{:token => token, :refresh_token => refresh_token})
  #       |> Changeset.put_assoc(:user, user)

  #     case Repo.update(auth_provider_session_changeset) do
  #       {:ok, updated_auth_provider_session} ->
  #         {:ok, updated_auth_provider_session}

  #       {:error, error} ->
  #         {:error, error}

  #       _ ->
  #         {:error, "Erreur lors de l'authentification"}
  #     end
  #   end

  #   def session_by_token(token) do
  #     AuthProviderSession
  #     |> where(token: ^token)
  #     |> preload([{:user, [:auth_user_default]}])
  #     |> Repo.one()
  #     |> case do
  #       session -> {:ok, session}
  #       nil -> {:error, "invalid authorization token"}
  #     end
  #   end
end
