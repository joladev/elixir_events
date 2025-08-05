defmodule ElixirEvents.RateLimitTest do
  use ExUnit.Case, async: false

  alias ElixirEvents.RateLimit

  setup do
    # Clear any existing rate limit data before each test
    :ok
  end

  describe "check_event_proposal/1" do
    test "allows requests within rate limit" do
      # Use a unique IP for this test to avoid conflicts
      ip = "test-ip-#{System.unique_integer()}"

      # First 6 requests should be allowed
      for _ <- 1..6 do
        assert {:allow, _count} = RateLimit.check_event_proposal(ip)
      end

      # 7th request should be denied
      assert {:deny, _ms_until_reset} = RateLimit.check_event_proposal(ip)
    end

    test "different IPs have separate rate limits" do
      # Use unique IPs for this test
      ip1 = "test-ip1-#{System.unique_integer()}"
      ip2 = "test-ip2-#{System.unique_integer()}"

      # Make 6 requests from first IP
      for _ <- 1..6 do
        assert {:allow, _count} = RateLimit.check_event_proposal(ip1)
      end

      # First IP should be rate limited
      assert {:deny, _ms_until_reset} = RateLimit.check_event_proposal(ip1)

      # Second IP should still be allowed
      assert {:allow, _count} = RateLimit.check_event_proposal(ip2)
    end
  end
end
