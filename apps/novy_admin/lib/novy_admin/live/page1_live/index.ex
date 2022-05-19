defmodule NovyAdmin.Page1Live.Index do
  @moduledoc false

  use NovyAdmin, :live_view
  on_mount NovyAdmin.UserLiveAuth

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
