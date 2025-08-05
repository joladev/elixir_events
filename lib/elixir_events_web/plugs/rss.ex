defmodule ElixirEventsWeb.Plugs.RSS do
  @moduledoc """
  Plug that handles RSS feed generation for Elixir events.

  Intercepts requests to /rss and returns an XML RSS feed containing
  approved events from the system.
  """
  import Plug.Conn

  alias ElixirEvents.Events.Event

  def init(opts), do: opts

  def call(%Plug.Conn{request_path: "/rss"} = conn, _opts) do
    body = render()

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, body)
    |> halt()
  end

  def call(conn, _opts), do: conn

  defp render do
    events = ElixirEvents.Events.rss()

    """
    <?xml version="1.0" encoding="UTF-8" ?>
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <title>ElixirEvents</title>
        <description>Elixir events</description>
        <link>https://elixirevents.net/</link>
        <lastBuildDate>#{pub_date(events)}</lastBuildDate>
        <pubDate>#{pub_date(events)}</pubDate>
        <ttl>1800</ttl>
        <atom:link href="https://elixirevents.net/rss" rel="self" type="application/rss+xml" />

        #{Enum.map_join(events, &render_event/1)}
      </channel>
    </rss>
    """
  end

  def render_event(event) do
    description =
      [
        "#{String.capitalize(Atom.to_string(event.type))} in #{event.city}, #{event.country} on #{Event.format_date(event.starts_at, event.ends_at, event.timezone)}.",
        event.description,
        "Read more at: #{event.url}"
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("<br/><br/>")

    """
    <item>
      <title><![CDATA[#{event.title}]]></title>
      <description><![CDATA[#{description}]]></description>
      <link>https://elixirevents.net/events/#{event.slug}</link>
      <pubDate>#{pub_date(event)}</pubDate>
      <guid>https://elixirevents.net/events/#{event.slug}</guid>
    </item>
    """
  end

  def pub_date(nil), do: ""
  def pub_date(events) when is_list(events), do: pub_date(List.first(events))
  def pub_date(event), do: format_rfc822(event.inserted_at)

  def format_rfc822(date_time), do: Calendar.strftime(date_time, "%a, %d %b %Y %H:%M:%S %Z")
end
