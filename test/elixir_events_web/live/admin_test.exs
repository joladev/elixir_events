defmodule ElixirEventsWeb.Live.AdminTest do
  use ElixirEventsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import ElixirEvents.AccountsFixtures

  alias ElixirEvents.Events

  describe "Admin LiveView" do
    test "requires authentication", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/users/log_in"}}} = live(conn, ~p"/admin")
    end

    test "shows events and allows approval", %{conn: conn} do
      # Create admin user and log in
      admin = admin_fixture()
      conn = log_in_user(conn, admin)

      # Create an unapproved event
      {:ok, event} =
        Events.register_event(%{
          title: "Pending Approval",
          type: :conference,
          url: "https://example.com",
          starts_at: ~N[2025-12-01 10:00:00],
          ends_at: ~N[2025-12-02 18:00:00],
          timezone: "UTC",
          city: "London",
          country: "United Kingdom",
          approved: false,
          online_only: false,
          description: "A great conference about Elixir"
        })

      {:ok, lv, html} = live(conn, ~p"/admin")

      # Check event appears in admin view
      assert html =~ "Pending Approval"
      assert html =~ "Edit"

      # Click edit button to open modal
      lv
      |> element("button", "Edit")
      |> render_click(%{id: event.id})

      # Check the approved checkbox
      html =
        lv
        |> form("#event_form", %{
          event: %{
            approved: true
          }
        })
        |> render_submit()

      # Should show success message
      assert html =~ "Updated"

      # Verify event is approved in database
      updated_event = Events.get(event.id)
      assert updated_event.approved == true
    end

    test "shows unchecked suggestions", %{conn: conn} do
      admin = admin_fixture()
      conn = log_in_user(conn, admin)

      # Create event with suggestion
      {:ok, event} =
        Events.register_event(%{
          title: "Event with Suggestion",
          type: :meetup,
          url: "https://example.com",
          starts_at: ~N[2025-12-15 19:00:00],
          ends_at: ~N[2025-12-15 21:00:00],
          timezone: "Europe/Stockholm",
          city: "Stockholm",
          country: "Sweden",
          approved: true,
          online_only: false,
          description: "Monthly Elixir meetup in Stockholm"
        })

      {:ok, _suggestion} =
        Events.make_suggestion(%{
          event_id: event.id,
          title: "Better Title",
          description: "Improved description"
        })

      {:ok, lv, html} = live(conn, ~p"/admin")

      # Should show the suggestion indicator
      assert html =~ "Event with Suggestion"
      assert html =~ "Edit"

      # Click edit to open modal with suggestions
      lv
      |> element("button", "Edit")
      |> render_click(%{id: event.id})

      # Modal should show the suggestion
      html = render(lv)
      assert html =~ "Suggestions"
      assert html =~ "Improved description"
    end

    test "allows event deletion", %{conn: conn} do
      admin = admin_fixture()
      conn = log_in_user(conn, admin)

      {:ok, event} =
        Events.register_event(%{
          title: "Delete This Event",
          type: :conference,
          url: "https://deleteme.com",
          starts_at: ~N[2025-12-20 10:00:00],
          ends_at: ~N[2025-12-20 18:00:00],
          timezone: "UTC",
          online_only: true,
          description: "Learn about Elixir online"
        })

      {:ok, lv, html} = live(conn, ~p"/admin")

      assert html =~ "Delete This Event"

      # Click delete button
      html =
        lv
        |> element(~s|button[phx-click="delete"][phx-value-id="#{event.id}"]|)
        |> render_click()

      # Event should be gone
      refute html =~ "Delete This Event"

      # Verify deletion in database
      assert nil == Events.get(event.id)
    end
  end
end
