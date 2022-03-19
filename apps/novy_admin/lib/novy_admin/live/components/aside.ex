defmodule NovyAdmin.ComponentLive.Aside do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <aside id="aside" class="aside fixed z-40 h-full bg-slate-800 flex flex-col">
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
          <%= live_patch "home", to: Routes.page_path(@socket, :index) %>

            <a class="flex items-center" href="javascript:;">
              <div class="ml-3">
                Dashboard
              </div>
            </a>
          </li>
          <li>
            <a class="flex items-center" href="javascript:;">
              <div class="ml-3">
                Utilisateurs
              </div>
            </a>
          </li>
          <li>
            <a class="flex items-center" href="javascript:;">
              <div class="ml-3">
                Paramètrage
              </div>
            </a>
            <ul>
              <li>
                <a href="javascript:;">
                  Dashboard
                </a>
              </li>
              <li>
                <a href="javascript:;">
                  Utilisateurs
                </a>
              </li>
              <li>
                <a href="javascript:;">
                  Paramètrage
                </a>
              </li>
            </ul>
          </li>
        </ul>
      </nav>
    </aside>
    """
  end
end
