defmodule ElixirEventsWeb.Live.EventTest do
  use ElixirEventsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias ElixirEvents.Events.Event
  alias ElixirEvents.Repo

  describe "Event LiveView" do
    test "sanitizes XSS in event description", %{conn: conn} do
      # Create an event with XSS attempt in description
      {:ok, event} =
        %{
          title: "Test Event",
          description: "Hello <script>alert('XSS')</script> world",
          url: "https://example.com",
          online_only: true,
          starts_at: ~U[2025-01-20 10:00:00Z],
          ends_at: ~U[2025-01-20 18:00:00Z],
          country: "United States",
          city: "New York",
          timezone: "America/New_York",
          approved: true,
          type: "conference"
        }
        |> Event.create_changeset()
        |> Repo.insert()

      # Extract the event_id and date from the slug
      [event_id, date] = String.split(event.slug, "/")

      # Visit the event page
      {:ok, _view, html} = live(conn, ~p"/events/#{event_id}/#{date}")

      # Verify script tag is removed but content is preserved
      refute html =~ "<script>"
      refute html =~ "alert('XSS')"
      assert html =~ "Hello"
      assert html =~ "world"
    end
  end
end
