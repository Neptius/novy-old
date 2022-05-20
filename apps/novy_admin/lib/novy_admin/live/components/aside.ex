defmodule NovyAdmin.ComponentLive.Aside do
  @moduledoc false

  use NovyAdmin, :live_component

  def render(assigns) do
    ~H"""
    <aside id="aside" class="aside sticky z-40 h-screen top-0 bg-slate-800 flex flex-col">
      <.live_component module={NovyAdmin.ComponentLive.Backdrop} id="backdrop" />

      <div class="h-16 flex items-center justify-between bg-teal-500 text-white px-5">
        <h1 class="chakra-petch text-2xl font-medium tracking-widest uppercase">
          Novy
        </h1>
        <span class="nv-badge">
          v0.1
        </span>
      </div>

      <nav class="nv-nav mt-2">
        <ul>
          <li>
            <%= live_redirect to: Routes.home_index_path(@socket, :index) do %>
              Home
            <% end %>
          </li>
          <li>
            <%= live_redirect to: Routes.page1_index_path(@socket, :index) do %>
              Page 1
            <% end %>
          </li>
          <li>
            <%= live_redirect to: Routes.page2_index_path(@socket, :index) do %>
              Page 2
            <% end %>
          </li>
          <li>
            <%= live_redirect to: Routes.page3_index_path(@socket, :index) do %>
              Page 3
            <% end %>
          </li>
          <li>
            <%= live_redirect to: Routes.page4_index_path(@socket, :index) do %>
              Page 4
            <% end %>
          </li>
          <li>
            <%= live_redirect to: Routes.page5_index_path(@socket, :index) do %>
              Page 5
            <% end %>
          </li>
        </ul>
      </nav>
    </aside>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
