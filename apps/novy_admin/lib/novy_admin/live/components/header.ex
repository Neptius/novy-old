defmodule NovyAdmin.ComponentLive.Header do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <header id="header" class="header bg-slate-600"></header>
    """
  end
end
