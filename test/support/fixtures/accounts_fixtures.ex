defmodule ElixirEvents.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ElixirEvents.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> ElixirEvents.Accounts.register_user()

    user
  end

  def admin_fixture do
    {:ok, user} = ElixirEvents.Accounts.register_super_user()

    # {encoded_token, user_token} = Xochitl.Accounts.UserToken.build_email_token(user, "confirm")
    # Xochitl.Repo.insert!(user_token)
    # {:ok, user} = Xochitl.Accounts.confirm_user(encoded_token)

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
