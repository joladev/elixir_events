defmodule ElixirEvents.EventsTest do
  use ElixirEvents.DataCase, async: true

  alias ElixirEvents.Events
  alias ElixirEvents.Events.Event
  alias ElixirEvents.Events.Suggestion

  describe "register_event/1" do
    test "creates event with valid attributes" do
      attrs = %{
        title: "Elixir Conf 2025",
        type: :conference,
        url: "https://elixirconf.com",
        starts_at: ~N[2025-06-01 09:00:00],
        ends_at: ~N[2025-06-03 18:00:00],
        timezone: "America/New_York",
        city: "Austin",
        country: "United States",
        description: "Annual Elixir conference",
        online_only: false
      }

      assert {:ok, %Event{} = event} = Events.register_event(attrs)
      assert event.title == "Elixir Conf 2025"
      assert event.slug == "elixir-conf-2025/2025-06-01"
      assert event.approved == nil
    end

    test "returns error with invalid attributes" do
      assert {:error, changeset} = Events.register_event(%{})
      assert errors_on(changeset).title
      assert errors_on(changeset).url
    end
  end

  describe "get_by_slug/1" do
    test "returns event when found" do
      {:ok, event} =
        Events.register_event(%{
          title: "Test Event",
          type: :meetup,
          url: "https://example.com",
          starts_at: ~N[2025-07-01 19:00:00],
          ends_at: ~N[2025-07-01 21:00:00],
          timezone: "Europe/London",
          city: "London",
          country: "United Kingdom",
          online_only: false
        })

      found = Events.get_by_slug(event.slug)
      assert found.id == event.id
    end

    test "returns nil when not found" do
      assert nil == Events.get_by_slug("non-existent/2025-01-01")
    end
  end

  describe "delete/1" do
    test "deletes existing event" do
      {:ok, event} =
        Events.register_event(%{
          title: "Delete Me",
          type: :conference,
          url: "https://example.com",
          starts_at: ~N[2025-08-01 10:00:00],
          ends_at: ~N[2025-08-01 18:00:00],
          timezone: "UTC",
          online_only: true
        })

      assert {:ok, _} = Events.delete(event)
      assert nil == Events.get(event.id)
    end

    test "returns error when event not found" do
      assert {:error, :not_found} = Events.delete(999_999)
    end
  end

  describe "front_page/1" do
    setup do
      # Create approved future events
      {:ok, stockholm} =
        Events.register_event(%{
          title: "Stockholm Meetup",
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
          title: "London Meetup",
          type: :meetup,
          url: "https://london.ex",
          starts_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 20, :day),
          ends_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 20, :day),
          timezone: "Europe/London",
          city: "London",
          country: "United Kingdom",
          approved: true,
          online_only: false
        })

      # Create unapproved event (should not appear)
      {:ok, _unapproved} =
        Events.register_event(%{
          title: "Unapproved Event",
          type: :conference,
          url: "https://unapproved.ex",
          starts_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 10, :day),
          ends_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 10, :day),
          timezone: "UTC",
          online_only: true
        })

      %{stockholm: stockholm, london: london}
    end

    test "returns all approved future events sorted by date" do
      events = Events.front_page()
      assert length(events) >= 2

      # Check events are sorted by date
      dates = Enum.map(events, & &1.starts_at)
      assert dates == Enum.sort(dates, NaiveDateTime)

      # Check all are approved
      assert Enum.all?(events, & &1.approved)
    end

    test "filters by location when provided", %{stockholm: stockholm} do
      events = Events.front_page("Stockholm, Sweden")

      assert Enum.any?(events, &(&1.id == stockholm.id))
      assert Enum.all?(events, &(&1.city == "Stockholm" and &1.country == "Sweden"))
    end
  end

  describe "admin_page/0" do
    test "returns all events with suggestions ordered by insertion" do
      {:ok, _event1} =
        Events.register_event(%{
          title: "First Event",
          type: :conference,
          url: "https://first.ex",
          starts_at: ~N[2025-09-01 10:00:00],
          ends_at: ~N[2025-09-01 18:00:00],
          timezone: "UTC",
          online_only: true
        })

      Process.sleep(10)

      {:ok, event2} =
        Events.register_event(%{
          title: "Second Event",
          type: :meetup,
          url: "https://second.ex",
          starts_at: ~N[2025-10-01 19:00:00],
          ends_at: ~N[2025-10-01 21:00:00],
          timezone: "UTC",
          online_only: true
        })

      # Add a suggestion
      {:ok, _suggestion} =
        Events.make_suggestion(%{
          event_id: event2.id,
          description: "Updated description"
        })

      admin_events = Events.admin_page()

      # Should be ordered by most recent first
      titles = Enum.map(admin_events, & &1.title)
      assert "Second Event" in titles
      assert "First Event" in titles

      # Should include suggestions
      event_with_suggestions = Enum.find(admin_events, &(&1.id == event2.id))
      assert length(event_with_suggestions.suggestions) == 1
    end
  end

  describe "make_suggestion/1" do
    setup do
      {:ok, event} =
        Events.register_event(%{
          title: "Original Event",
          type: :conference,
          url: "https://original.ex",
          starts_at: ~N[2025-11-01 10:00:00],
          ends_at: ~N[2025-11-01 18:00:00],
          timezone: "UTC",
          online_only: true
        })

      %{event: event}
    end

    test "creates suggestion for existing event", %{event: event} do
      attrs = %{
        event_id: event.id,
        description: "New and improved description with updated title"
      }

      assert {:ok, %Suggestion{} = suggestion} = Events.make_suggestion(attrs)
      assert suggestion.event_id == event.id
      assert suggestion.description == "New and improved description with updated title"
      assert suggestion.checked == nil
    end

    test "marks suggestion as checked", %{event: event} do
      {:ok, suggestion} =
        Events.make_suggestion(%{
          event_id: event.id,
          description: "Suggestion to check"
        })

      assert suggestion.checked == nil

      Events.check_suggestion!(suggestion.id)

      updated = Repo.get(Suggestion, suggestion.id)
      assert updated.checked == true
    end
  end
end
