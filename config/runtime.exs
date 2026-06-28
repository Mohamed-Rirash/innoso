import Config

# Enable the server when PHX_SERVER env var is set (used by bin/server script)
if System.get_env("PHX_SERVER") do
  config :innoso, InnosoWeb.Endpoint, server: true
end

# Always bind HTTP to the configured port on all interfaces
config :innoso, InnosoWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT", "4000")),
    ip: {0, 0, 0, 0, 0, 0, 0, 0}
  ]

if config_env() == :prod do
  # --- Database ---
  database_path =
    System.get_env("DATABASE_PATH") ||
      raise "environment variable DATABASE_PATH is missing. Example: /data/innoso/innoso.db"

  config :innoso, Innoso.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  # --- Secret key ---
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "environment variable SECRET_KEY_BASE is missing. Generate one with: mix phx.gen.secret"

  # --- Endpoint ---
  host = System.get_env("PHX_HOST") || raise "environment variable PHX_HOST is missing."

  config :innoso, InnosoWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    secret_key_base: secret_key_base

  # --- DNS clustering (optional) ---
  config :innoso, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  # --- Mailer (Resend) ---
  if resend_key = System.get_env("RESEND_API_KEY") do
    config :innoso, Innoso.Mailer,
      adapter: Swoosh.Adapters.Resend,
      api_key: resend_key
  end
end
