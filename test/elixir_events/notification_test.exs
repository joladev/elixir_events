defmodule ElixirEvents.NotificationTest do
  use ElixirEvents.DataCase, async: true
  use Mimic

  alias ElixirEvents.Notification

  describe "push/1" do
    test "sends notification when push is enabled" do
      expect(Req, :post, fn url, opts ->
        assert url == "https://api.pushover.net/1/messages.json"
        assert opts[:form][:token] == "test_token"
        assert opts[:form][:user] == "test_group"
        assert opts[:form][:message] == "Test notification"
        {:ok, %Req.Response{status: 200}}
      end)

      assert {:ok, %Req.Response{status: 200}} = Notification.push("Test notification")
    end
  end
end
