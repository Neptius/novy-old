defmodule NovyAdmin.ComponentLive.Header do
  @moduledoc false

  use Phoenix.LiveComponent

  alias Phoenix.LiveView.JS

  def render(assigns) do
    ~H"""
    <header id="header" class="header bg-slate-600 flex items-center">
      <div class="flex justify-between mx-5">
        <div class="nv-header-left">

          <button>
            <FontAwesome.LiveView.icon name="bars" type="solid" class="h-6 w-6 text-white fill-current" />
          </button>

        </div>
        <div class="nv-header-middle"></div>
        <div class="nv-header-right"></div>
      </div>
    </header>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
