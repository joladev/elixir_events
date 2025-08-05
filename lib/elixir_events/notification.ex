defmodule ElixirEvents.Notification do
  @moduledoc """
  Module for sending push notifications via Pushover API.

  Used to notify administrators about new events or suggestions
  that require review.
  """
  def push(message) do
    if Application.fetch_env!(:elixir_events, :push_enabled) do
      case Req.post("https://api.pushover.net/1/messages.json",
             form: %{
               token: Application.fetch_env!(:elixir_events, :push_token),
               user: Application.fetch_env!(:elixir_events, :push_group),
               message: message
             }
           ) do
        {:ok, %Req.Response{status: 200}} = result ->
          result

        other ->
          Sentry.capture_message("failed to send notification", extra: other)
      end
    end
  end
end
