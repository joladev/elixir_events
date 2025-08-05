defmodule ElixirEventsWeb.Plugs.RSSTest do
  use ElixirEvents.DataCase, async: true
  import Plug.Test

  alias ElixirEventsWeb.Plugs.RSS

  describe "call/2" do
    test "returns RSS XML for /rss path" do
      conn = conn(:get, "/rss")
      conn = RSS.call(conn, [])

      assert conn.status == 200

      assert Enum.any?(conn.resp_headers, fn {k, v} ->
               k == "content-type" && v == "application/xml; charset=utf-8"
             end)

      assert conn.resp_body =~ "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
      assert conn.resp_body =~ "<rss version=\"2.0\""
    end
  end
end
