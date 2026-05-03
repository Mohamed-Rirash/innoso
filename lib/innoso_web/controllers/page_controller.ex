defmodule InnosoWeb.PageController do
  use InnosoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
