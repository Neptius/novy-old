defmodule NovyAdmin.ComponentLive.Header do
  @moduledoc false

  use Phoenix.LiveComponent

  alias Phoenix.LiveView.JS

  def render(assigns) do
    ~H"""
    <header id="header" class="header bg-slate-600 flex items-center">
      <div class="flex justify-between mx-5">
        <div class="nv-header-left">

          <button phx-click={toggle_menu()}>
            <FontAwesome.LiveView.icon name="bars" type="solid" class="h-6 w-6 text-white fill-current" />
          </button>

        </div>
        <div class="nv-header-middle"></div>
        <div class="nv-header-right"></div>
      </div>
    </header>
    """
  end

  def toggle_menu(js \\ %JS{}) do
    case collapse do
      true ->
        js
        |> JS.add_class("is-collapsed", to: "#wrapper")

      _ ->
        js
        |> JS.remove_class("is-collapsed", to: "#wrapper")
    end
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
