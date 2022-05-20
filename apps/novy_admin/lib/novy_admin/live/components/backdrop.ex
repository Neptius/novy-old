defmodule NovyAdmin.ComponentLive.Backdrop do
  @moduledoc false

  use Phoenix.LiveComponent

  alias Phoenix.LiveView.JS

  def render(assigns) do
    ~H"""
    <div
      id="backdrop"
      phx-click={close_nav()}
      class="backdrop bg-black/25 h-screen fixed w-full lg:hidden"
    >
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def close_nav(js \\ %JS{}) do
    js
    |> JS.remove_class(
      "nav-open",
      to: ".aside.nav-open"
    )
  end
end
