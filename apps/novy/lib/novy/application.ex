defmodule Novy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Novy.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Novy.PubSub}
      # Start a worker by calling: Novy.Worker.start_link(arg)
      # {Novy.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Novy.Supervisor)
  end
end
