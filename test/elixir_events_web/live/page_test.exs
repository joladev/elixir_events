defmodule ElixirEventsWeb.Live.PageTest do
  use ElixirEventsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  alias ElixirEvents.Events

  describe "Page LiveView" do
    setup do
      # Create some test events
      {:ok, stockholm} =
        Events.register_event(%{
          title: "Stockholm Elixir Meetup",
          type: :meetup,
          url: "https://stockholm.ex",
          starts_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 30, :day),
          ends_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 30, :day),
          timezone: "Europe/Stockholm",
          city: "Stockholm",
          country: "Sweden",
          approved: true,
          online_only: false
        })

      {:ok, london} =
        Events.register_event(%{
          title: "London BEAM Day",
          type: :conference,
          url: "https://london.ex",
          starts_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 45, :day),
          ends_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 45, :day),
          timezone: "Europe/London",
          city: "London",
          country: "United Kingdom",
          approved: true,
          online_only: false
        })

      %{stockholm: stockholm, london: london}
    end

    test "filters events by location", %{conn: conn, stockholm: stockholm, london: london} do
      {:ok, lv, html} = live(conn, ~p"/")

      # Initially shows all events
      assert html =~ stockholm.title
      assert html =~ london.title

      # Filter by Stockholm using the update-options event directly
      render_change(lv, "update-options", %{location: "Stockholm, Sweden"})

      html = render(lv)

      # Should only show Stockholm event
      assert html =~ stockholm.title
      refute html =~ london.title

      # Clear filter
      render_change(lv, "update-options", %{location: nil})

      html = render(lv)

      # Should show all events again
      assert html =~ stockholm.title
      assert html =~ london.title
    end

    test "only shows approved future events", %{conn: conn} do
      # Create past event (should not show)
      {:ok, _past} =
        Events.register_event(%{
          title: "Past Event",
          type: :meetup,
          url: "https://past.ex",
          starts_at: NaiveDateTime.add(NaiveDateTime.utc_now(), -10, :day),
          ends_at: NaiveDateTime.add(NaiveDateTime.utc_now(), -10, :day),
          timezone: "UTC",
          approved: true,
          online_only: true
        })

      # Create unapproved event (should not show)
      {:ok, _unapproved} =
        Events.register_event(%{
          title: "Unapproved Event",
          type: :conference,
          url: "https://unapproved.ex",
          starts_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 60, :day),
          ends_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 60, :day),
          timezone: "UTC",
          approved: false,
          online_only: true
        })

      {:ok, _lv, html} = live(conn, ~p"/")

      # Should not show past or unapproved events
      refute html =~ "Past Event"
      refute html =~ "Unapproved Event"
    end
  end
end
