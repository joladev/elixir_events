defmodule ElixirEventsWeb.Controllers.Page do
  @moduledoc """
  Controller for static pages.

  Currently handles the home page rendering.
  """
  use ElixirEventsWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end
