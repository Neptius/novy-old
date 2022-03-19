defmodule NovyAdmin.ComponentLive.Header do
  @moduledoc false

  use NovyAdmin, :live_component

  def render(assigns) do
    ~H"""
    <header id="header" class="header bg-slate-600"></header>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
