defmodule ElixirEventsWeb.Plugs.HealthCheckTest do
  use ExUnit.Case, async: true
  import Plug.Test

  alias ElixirEventsWeb.Plugs.HealthCheck

  describe "call/2" do
    test "returns 200 for /health path" do
      conn = conn(:get, "/health")
      conn = HealthCheck.call(conn, [])

      assert conn.status == 200
      assert conn.resp_body == ""
      assert conn.halted
    end
  end
end
