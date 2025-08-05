defmodule ElixirEvents.Events.Event do
  @moduledoc """
  Ecto schema for events in the Elixir ecosystem.

  Represents conferences, meetups, and other community events with
  location, timing, and approval status information.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import TzExtra.Changeset

  alias ElixirEvents.Events.Suggestion

  schema "events" do
    field :starts_at, :utc_datetime
    field :ends_at, :utc_datetime
    field :title, :string
    field :url, :string
    field :logo_url, :string
    field :city, :string
    field :country, :string
    field :timezone, :string
    field :approved, :boolean
    field :type, Ecto.Enum, values: [:conference, :meetup]
    field :slug, :string
    field :description, :string
    field :online_only, :boolean

    has_many :suggestions, Suggestion

    timestamps(type: :utc_datetime)
  end

  def changeset(params) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(event, params) do
    changeset =
      event
      |> cast(params, [
        :starts_at,
        :ends_at,
        :title,
        :url,
        :logo_url,
        :city,
        :country,
        :timezone,
        :approved,
        :type,
        :slug,
        :description,
        :online_only
      ])
      |> validate_required([
        :starts_at,
        :title,
        :url,
        :timezone,
        :type,
        :online_only
      ])
      |> validate_time_zone_id(:timezone, allow_alias: true)

    if get_change(changeset, :online_only) || Map.get(event, :online_only) do
      changeset
    else
      validate_required(changeset, [:city, :country])
    end
  end

  def create_changeset(params) do
    changeset = changeset(%__MODULE__{}, params)

    if changeset.valid? do
      title = get_change(changeset, :title)
      starts_at = get_change(changeset, :starts_at)
      date = Calendar.strftime(starts_at, "%Y-%m-%d")
      slug = "#{Slug.slugify(title)}/#{date}"

      put_change(changeset, :slug, slug)
    else
      changeset
    end
  end

  def format_date(starts_at, ends_at, timezone) do
    {:ok, starts_at} = DateTime.from_naive(starts_at, timezone, Tz.TimeZoneDatabase)
    {:ok, ends_at} = DateTime.from_naive(ends_at, timezone, Tz.TimeZoneDatabase)

    cond do
      starts_at.day == ends_at.day ->
        "#{fmt(starts_at, "%H:%M")}-#{fmt(ends_at, "%H:%M %d %b, %Y %Z")}"

      starts_at.month == ends_at.month ->
        "#{fmt(starts_at, "%d")}-#{fmt(ends_at, "%d")} #{fmt(starts_at, "%b, %Y %Z")}"

      true ->
        "#{fmt(starts_at, "%d %b")}-#{fmt(ends_at, "%d %b")}, #{fmt(starts_at, "%Y %Z")}"
    end
  end

  def truncate(string, length \\ 120) do
    if String.length(string) > length do
      suffix = "..."
      without_suffix = length - String.length(suffix)

      String.slice(string, 0..without_suffix) <> "..."
    else
      string
    end
  end

  defp fmt(date, string) do
    Calendar.strftime(date, string)
  end
end
