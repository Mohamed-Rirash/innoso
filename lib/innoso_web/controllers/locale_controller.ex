defmodule InnosoWeb.LocaleController do
  use InnosoWeb, :controller

  @supported_locales ~w(en ar so fr)

  def set(conn, %{"locale" => locale}) when locale in @supported_locales do
    conn
    |> put_session(:locale, locale)
    |> redirect(to: referer_or_home(conn))
  end

  def set(conn, _params), do: redirect(conn, to: ~p"/")

  defp referer_or_home(conn) do
    case get_req_header(conn, "referer") do
      [referer | _] -> URI.parse(referer).path || "/"
      [] -> "/"
    end
  end
end
