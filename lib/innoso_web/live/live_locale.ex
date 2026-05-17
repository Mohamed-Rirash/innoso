defmodule InnosoWeb.LiveLocale do
  @supported_locales ~w(en ar so fr)

  def on_mount(:default, _params, session, socket) do
    locale = Map.get(session, "locale", "en")
    locale = if locale in @supported_locales, do: locale, else: "en"
    Gettext.put_locale(InnosoWeb.Gettext, locale)
    {:cont, Phoenix.Component.assign(socket, :locale, locale)}
  end
end
