defmodule ElixirEvents.BlueskyTest do
  use ElixirEvents.DataCase, async: true
  use Mimic

  alias ElixirEvents.Bluesky
  alias ElixirEvents.Events

  describe "post/1" do
    test "posts event to Bluesky with correct formatting" do
      {:ok, event} =
        Events.register_event(%{
          title: "Elixir Conf EU 2025",
          type: :conference,
          url: "https://elixirconf.eu",
          starts_at: ~N[2025-06-15 09:00:00],
          ends_at: ~N[2025-06-17 18:00:00],
          timezone: "Europe/Berlin",
          city: "Berlin",
          country: "Germany",
          description:
            "The biggest Elixir conference in Europe! Join us for three days of talks, workshops, and networking.",
          approved: true,
          online_only: false
        })

      # Mock the login request
      Req
      |> expect(:post, fn "https://bsky.social/xrpc/com.atproto.server.createSession", opts ->
        assert opts[:body] =~ "identifier"
        assert opts[:body] =~ "password"

        {:ok,
         %Req.Response{
           body: %{
             "did" => "did:plc:test123",
             "accessJwt" => "fake-jwt-token",
             "refreshJwt" => "fake-refresh-token"
           }
         }}
      end)

      # Mock the post creation request
      |> expect(:post, fn "https://bsky.social/xrpc/com.atproto.repo.createRecord", opts ->
        body = JSON.decode!(opts[:body])

        assert body["collection"] == "app.bsky.feed.post"
        assert body["repo"] == "did:plc:test123"
        assert body["record"]["text"] =~ "Elixir Conf EU 2025"
        assert body["record"]["text"] =~ "Berlin, Germany"
        assert body["record"]["text"] =~ "#ElixirLang"
        assert body["record"]["text"] =~ "https://elixirevents.net/events/#{event.slug}"

        # Check facets for link and hashtag
        facets = body["record"]["facets"]
        assert length(facets) == 2

        assert Enum.any?(
                 facets,
                 fn facet ->
                   facet["features"]
                   |> hd()
                   |> Map.get("$type") == "app.bsky.richtext.facet#link"
                 end
               )

        assert Enum.any?(
                 facets,
                 fn facet ->
                   facet["features"]
                   |> hd()
                   |> Map.get("$type") == "app.bsky.richtext.facet#tag"
                 end
               )

        {:ok, %Req.Response{body: %{"uri" => "at://did:plc:test123/app.bsky.feed.post/123"}}}
      end)

      assert {:ok, _} = Bluesky.post(event)
    end

    test "text formatting truncates long descriptions" do
      event = %ElixirEvents.Events.Event{
        title: "Test Event",
        city: "Stockholm",
        country: "Sweden",
        starts_at: ~N[2025-07-01 10:00:00],
        ends_at: ~N[2025-07-01 18:00:00],
        timezone: "Europe/Stockholm",
        description: String.duplicate("Very long description. ", 50),
        slug: "test-event/2025-07-01",
        online_only: false
      }

      text = Bluesky.text(event)

      # Should include all key elements
      assert text =~ "Test Event"
      assert text =~ "Stockholm, Sweden"
      assert text =~ "#ElixirLang"
      assert text =~ "https://elixirevents.net/events/test-event/2025-07-01"

      # Should include emoji
      assert String.match?(text, ~r/[💫🚀📣✨⭐️🌟🙌🥳🤩🔥☀️]/)

      # Description should be truncated
      assert String.length(text) < String.length(event.description)
    end

    test "handles online-only events without location in date formatting" do
      event = %ElixirEvents.Events.Event{
        title: "Online Workshop",
        city: "Online",
        country: "Online",
        starts_at: ~N[2025-08-01 14:00:00],
        ends_at: ~N[2025-08-01 17:00:00],
        timezone: "UTC",
        description: "Learn Elixir online",
        slug: "online-workshop/2025-08-01",
        online_only: true
      }

      text = Bluesky.text(event)

      # Should not include date formatting for online-only events
      refute text =~ ~r/\d{1,2}\s+\w+\s+\d{4}/
      assert text =~ "Online Workshop"
      assert text =~ "Learn Elixir online"
    end
  end
end
