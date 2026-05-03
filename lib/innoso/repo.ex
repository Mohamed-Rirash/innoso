defmodule Innoso.Repo do
  use Ecto.Repo,
    otp_app: :innoso,
    adapter: Ecto.Adapters.SQLite3
end
