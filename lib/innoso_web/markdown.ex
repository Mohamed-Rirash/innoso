defmodule InnosoWeb.Markdown do
  def render(nil), do: ""
  def render(""), do: ""

  def render(text) do
    if Code.ensure_loaded?(Earmark) do
      case Earmark.as_html(text, escape: false, smartypants: false) do
        {:ok, html, _} -> html
        {:error, html, _} -> html
      end
    else
      text
    end
  end

  # Strips Markdown/HTML to clean plain text — suitable for truncated card previews.
  def plain_text(nil), do: ""
  def plain_text(""), do: ""

  def plain_text(text) do
    text
    |> render()
    |> String.replace(~r/<[^>]+>/s, " ")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
