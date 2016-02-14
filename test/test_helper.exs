ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Pylon.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Pylon.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Pylon.Repo)

