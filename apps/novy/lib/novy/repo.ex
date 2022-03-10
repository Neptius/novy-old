defmodule Novy.Repo do
  use Ecto.Repo,
    otp_app: :novy,
    adapter: Ecto.Adapters.Postgres
end
