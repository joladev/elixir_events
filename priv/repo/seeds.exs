# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirEvents.Repo.insert!(%ElixirEvents.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

ElixirEvents.Accounts.register_super_user()
ElixirEvents.Events.generate_test_data()
