defmodule ElixirEvents.Bluesky do
  @moduledoc """
  Integration module for posting events to Bluesky social network.

  Handles authentication and posting of approved events with proper
  formatting and hashtags.
  """
  alias ElixirEvents.Events.Event

  def post(%Event{} = event) do
    with {:ok, session} <- login() do
      headers = [
        {"Authorization", "Bearer #{session.access_token}"},
        {"Content-Type", "application/json"}
      ]

      text = text(event)
      link = link(event)
      {link_byte_start, link_byte_end} = find_indices(text, link)
      {tag_byte_start, tag_byte_end} = find_indices(text, "#ElixirLang")

      json = %{
        collection: "app.bsky.feed.post",
        repo: session.did,
        record: %{
          "$type": "app.bsky.feed.post",
          createdAt: DateTime.to_iso8601(DateTime.utc_now()),
          text: text,
          facets: [
            %{
              index: %{
                byteStart: link_byte_start,
                byteEnd: link_byte_end
              },
              features: [
                %{
                  "$type": "app.bsky.richtext.facet#link",
                  uri: link
                }
              ]
            },
            %{
              index: %{
                byteStart: tag_byte_start,
                byteEnd: tag_byte_end
              },
              features: [
                %{
                  "$type": "app.bsky.richtext.facet#tag",
                  tag: "ElixirLang"
                }
              ]
            }
          ]
        }
      }

      body = JSON.encode!(json)

      uri = "https://bsky.social/xrpc/com.atproto.repo.createRecord"

      Req.post(uri, body: body, headers: headers)
    end
  end

  def login do
    username = Application.fetch_env!(:elixir_events, :bluesky_username)
    password = Application.fetch_env!(:elixir_events, :bluesky_password)

    body = JSON.encode!(%{identifier: username, password: password})
    uri = "https://bsky.social/xrpc/com.atproto.server.createSession"
    headers = [{"Content-Type", "application/json"}]

    with {:ok,
          %Req.Response{
            body: %{"did" => did, "accessJwt" => access_token, "refreshJwt" => refresh_token}
          }} <- Req.post(uri, body: body, headers: headers) do
      {:ok,
       %{
         did: did,
         access_token: access_token,
         refresh_token: refresh_token
       }}
    end
  end

  def text(event) do
    chosen = emoji()

    [
      "#{chosen} #{event.title} #{chosen}\n",
      "#{event.city}, #{event.country}\n",
      format_date(event),
      "\n",
      "#{Event.truncate(event.description)}\n\n",
      "#{link(event)} #ElixirLang"
    ]
    |> Enum.reject(&is_nil/1)
    |> :erlang.iolist_to_binary()
  end

  def format_date(%ElixirEvents.Events.Event{online_only: true}), do: nil

  def format_date(event) do
    "#{Event.format_date(event.starts_at, event.ends_at, event.timezone)}\n"
  end

  def link(event) do
    "https://elixirevents.net/events/#{event.slug}"
  end

  def find_indices(text, link) do
    case Regex.run(~r/#{Regex.escape(link)}/u, text, return: :index) do
      [{start, length}] ->
        {start, start + length}
    end
  end

  defp emoji do
    Enum.random([
      "💫",
      "🚀",
      "📣",
      "✨",
      "⭐️",
      "🌟",
      "🙌",
      "🥳",
      "🤩",
      "🔥",
      "☀️"
    ])
  end
end
