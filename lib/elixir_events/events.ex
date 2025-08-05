defmodule ElixirEvents.Events do
  @moduledoc """
  Context module for managing events and suggestions.

  Provides the main API for creating, querying, and updating events
  in the system, including approval workflows and suggestion handling.
  """
  import Ecto.Query

  alias ElixirEvents.Events.Event
  alias ElixirEvents.Events.Suggestion
  alias ElixirEvents.Repo

  def register_event(attrs) do
    attrs
    |> Event.create_changeset()
    |> Repo.insert()
  end

  def make_suggestion(attrs) do
    attrs
    |> Suggestion.changeset()
    |> Repo.insert()
  end

  def check_suggestion!(id) do
    suggestion = Repo.get(Suggestion, id)

    changeset = Ecto.Changeset.change(suggestion, %{checked: true})
    Repo.update!(changeset)
  end

  def backfill_slugs do
    events = all()

    Enum.each(events, fn event ->
      date = Calendar.strftime(event.starts_at, "%Y-%m-%d")
      title = Slug.slugify(event.title)
      slug = "#{title}/#{date}"

      changeset = Event.changeset(event, %{slug: slug})
      Repo.update!(changeset)
    end)
  end

  def change(event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  def change_suggestion(event, attrs \\ %{}) do
    Suggestion.changeset(event, attrs)
  end

  def update(event, params) do
    changeset = Event.changeset(event, params)

    Repo.update(changeset)
  end

  def delete(%Event{} = event) do
    Repo.delete(event)
  end

  def delete(id) do
    {rows_deleted, _} = Repo.delete_all(from(x in Event, where: x.id == ^id))

    if rows_deleted == 1 do
      :ok
    else
      {:error, :not_found}
    end
  end

  def get(id) do
    Repo.get(Event, id)
  end

  def get_by_slug(slug) do
    Repo.one(from e in Event, where: e.slug == ^slug)
  end

  def get_with_unchecked_suggestions(id) do
    suggestions_query = unchecked_suggestions_query()
    Repo.one(from e in Event, where: e.id == ^id, preload: [suggestions: ^suggestions_query])
  end

  def all do
    Repo.all(all_query())
  end

  def admin_page do
    all_query()
    |> descending_by_inserted_at()
    |> preload([:suggestions])
    |> Repo.all()
  end

  def all_future do
    all_query()
    |> future()
    |> Repo.all()
  end

  def rss do
    all_query()
    |> ascending_by_inserted_at()
    |> approved()
    |> Repo.all()
  end

  def front_page(location_filter \\ nil) do
    query =
      all_query()
      |> approved()
      |> ascending()
      |> future()

    query =
      if location_filter do
        [city, country] = String.split(location_filter, ", ")
        where(query, [e], e.country == ^country and e.city == ^city)
      else
        query
      end

    Repo.all(query)
  end

  def all_query do
    from(e in Event)
  end

  def ascending(query) do
    order_by(query, asc: :starts_at)
  end

  def descending_by_inserted_at(query) do
    order_by(query, desc: :inserted_at)
  end

  def ascending_by_inserted_at(query) do
    order_by(query, asc: :inserted_at)
  end

  def future(query) do
    where(query, [e], e.starts_at > ^NaiveDateTime.utc_now())
  end

  def approved(query) do
    where(query, [e], e.approved)
  end

  def unchecked_suggestions(query) do
    preload_query = unchecked_suggestions_query()
    preload(query, suggestions: ^preload_query)
  end

  def unchecked_suggestions_query do
    from s in Suggestion, where: s.checked == false
  end

  def generate_test_data do
    title = "Stockholm Meetup"
    starts_at = NaiveDateTime.add(NaiveDateTime.utc_now(:second), 71, :day)
    date = Calendar.strftime(starts_at, "%Y-%m-%d")
    slug = Slug.slugify(title)

    description = """
    One day celebration of all things BEAM is coming to London!

    This event offers a unique opportunity to meet locally, learn from industry experts, and network with fellow Erlang, Elixir and Gleam enthusiasts.
    """

    register_event(%{
      title: title,
      type: :meetup,
      slug: "#{slug}/#{date}",
      starts_at: starts_at,
      ends_at: NaiveDateTime.add(starts_at, 2, :hour),
      url: "https://codebeamstockholm.com/",
      timezone: "Europe/Berlin",
      city: "Stockholm",
      country: "Sweden",
      approved: true,
      description: description,
      online_only: false
    })

    for index <- 1..40 do
      title = "Code BEAM Lite #{index}"
      increase = index + 30
      starts_at = NaiveDateTime.add(NaiveDateTime.utc_now(:second), increase, :day)
      date = Calendar.strftime(starts_at, "%Y-%m-%d")
      slug = Slug.slugify(title)

      register_event(%{
        title: title,
        type: :conference,
        slug: "#{slug}/#{date}",
        starts_at: NaiveDateTime.add(NaiveDateTime.utc_now(:second), increase, :day),
        ends_at: NaiveDateTime.add(NaiveDateTime.utc_now(:second), increase + 1, :day),
        url: "https://codebeamstockholm.com/",
        timezone: "Europe/Berlin",
        city: "Stockholm",
        country: "Sweden",
        approved: true,
        description: description,
        online_only: false
      })
    end
  end
end
