alias Innoso.Accounts

email = System.get_env("SEED_ADMIN_EMAIL", "admin@innoso.com")
password = System.get_env("SEED_ADMIN_PASSWORD", "Admin@innoso123!")

if is_nil(Accounts.get_admin_by_email(email)) do
  case Accounts.create_admin(%{email: email, password: password}) do
    {:ok, admin} ->
      IO.puts("Seed admin created: #{admin.email}")

    {:error, changeset} ->
      IO.puts("Failed to create seed admin: #{inspect(changeset.errors)}")
  end
else
  IO.puts("Seed admin already exists: #{email}")
end
