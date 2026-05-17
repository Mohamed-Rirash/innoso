defmodule InnosoWeb.Plugs.SetLocale do
  import Plug.Conn

  @supported_locales ~w(en ar so fr)

  def init(opts), do: opts

  def call(conn, _opts) do
    locale = get_session(conn, :locale) || "en"
    locale = if locale in @supported_locales, do: locale, else: "en"
    Gettext.put_locale(InnosoWeb.Gettext, locale)
    assign(conn, :locale, locale)
  end
end
