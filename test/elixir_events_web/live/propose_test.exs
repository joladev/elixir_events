defmodule ElixirEventsWeb.Live.ProposeTest do
  use ElixirEventsWeb.ConnCase, async: true
  use Mimic

  import Phoenix.LiveViewTest
  import ElixirEvents.AccountsFixtures

  describe "Propose" do
    setup [:verify_on_exit!, :set_mimic_from_context]

    setup %{conn: conn} do
      user = admin_fixture()
      %{conn: log_in_user(conn, user), user: user}
    end

    test "renders page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/propose")

      assert html =~ "ElixirEvents"
    end

    test "allows event submission within rate limit", %{conn: conn} do
      # Mock the rate limiter to allow the request
      expect(ElixirEvents.RateLimit, :check_event_proposal, fn _ip -> {:allow, 1} end)

      expect(ElixirEvents.Notification, :push, fn message ->
        assert message == "event created"
        nil
      end)

      {:ok, lv, _html} = live(conn, ~p"/propose")

      # Submit a valid event
      assert lv
             |> form("#event_form", %{
               event: %{
                 title: "Test Event",
                 type: "conference",
                 url: "https://example.com",
                 city: "Stockholm",
                 country: "Sweden",
                 starts_at: "2025-12-01T10:00",
                 ends_at: "2025-12-02T18:00",
                 timezone: "Europe/Stockholm"
               }
             })
             |> render_submit()

      # Should redirect after successful submission
      assert_redirect(lv, ~p"/")
    end

    test "shows error message when rate limited", %{conn: conn} do
      # Mock the rate limiter to deny the request
      expect(ElixirEvents.RateLimit, :check_event_proposal, fn _ip -> {:deny, 3_600_000} end)

      {:ok, lv, _html} = live(conn, ~p"/propose")

      # Try to submit an event (should be rate limited)
      html =
        lv
        |> form("#event_form", %{
          event: %{
            title: "Another Test Event",
            type: "conference",
            url: "https://example.com",
            city: "Stockholm",
            country: "Sweden",
            starts_at: "2025-12-01T10:00",
            ends_at: "2025-12-02T18:00",
            timezone: "Europe/Stockholm"
          }
        })
        |> render_submit()

      # Check that we see the error message and not a redirect
      assert html =~ "You&#39;ve submitted too many events. Please try again later."
    end
  end
end
