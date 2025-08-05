defmodule ElixirEvents.Events.EventTest do
  use ElixirEvents.DataCase, async: true

  alias ElixirEvents.Events.Event

  describe "changeset/2" do
    test "validates required fields" do
      changeset = Event.changeset(%Event{}, %{})

      assert errors_on(changeset).title
      assert errors_on(changeset).url
      assert errors_on(changeset).starts_at
      assert errors_on(changeset).timezone
      assert errors_on(changeset).type
    end
  end

  describe "format_date/3" do
    test "formats same day event" do
      starts_at = ~N[2025-06-15 09:00:00]
      ends_at = ~N[2025-06-15 17:00:00]

      result = Event.format_date(starts_at, ends_at, "America/New_York")

      assert result == "09:00-17:00 15 Jun, 2025 EDT"
    end
  end
end
