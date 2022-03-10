defmodule NovyAdmin.PageController do
  use NovyAdmin, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
