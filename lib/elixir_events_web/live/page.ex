defmodule ElixirEventsWeb.Live.Page do
  @moduledoc """
  Main page LiveView displaying a paginated list of approved Elixir events.

  Features location filtering and navigation to individual event pages.
  """
  use ElixirEventsWeb, :live_view

  alias ElixirEvents.Events.Event

  def render(assigns) do
    ~H"""
    <div class="w-[320px] md:w-[424px] place-self-center">
      <div class="flex flex-row place-content-between">
        <div class="w-fit mb-4 -mt-1.5">
          <.link
            class="text-orangey pl-2 border border-orangey border-2 ml-2 py-1 rounded-md hover:bg-slate-700"
            navigate={~p"/propose"}
          >
            Missing an event? <.icon name="hero-pencil h-[16px] w-[16px] -mt-1 mr-1" />
          </.link>
        </div>
        <div class="w-fit mb-4 -mt-4">
          <.link href="/rss">
            <.icon name="hero-rss place-self-end text-orangey" />
          </.link>
          <.button phx-click={show_modal("options")}>
            <.icon name="hero-adjustments-horizontal" />
          </.button>
          <.modal id="options">
            <.form for={%{}} id="options-form" phx-change="update-options">
              <div class="flex flex-row place-content-center">
                <.input
                  label="Location"
                  id="location"
                  name="location"
                  type="select"
                  options={options()}
                  value={nil}
                />
              </div>
            </.form>
          </.modal>
        </div>
      </div>
      <!-- filters here, eg by city/country -->
      <%= for event <- @events do %>
        <.link
          navigate={"/events/#{event.slug}"}
          class="border-highlight border-solid border-4 flex flex-col pb-4 pt-4 mb-6 mx-2 hover:border-highlightdarker"
        >
          <div class="flex flex-row">
            <div class="h-16 w-16 md:h-24 md:w-24 p-2 flex flex row place-content-center place-items-center">
              <%= if event.logo_url do %>
                <img
                  class="h-8 w-8 md:h-16 md:w-16"
                  alt={"Logo for #{event.title}"}
                  src={event.logo_url}
                />
              <% else %>
                <.icon class="h-16 w-16 text-highlight" name="hero-photo" />
              <% end %>
            </div>
            <div class="flex flex-col md:h-24 place-content-center">
              <!-- think about share buttons? -->
            <!-- should have an owner? -->
              <h2 class="text-lg md:text-2xl text-orangey">
                {event.title}
              </h2>
              <p class="text-lightblue text-sm md:text-base italic">
                <%= if event.online_only do %>
                  Online Only
                <% else %>
                  {event.city}, {event.country}
                <% end %>
              </p>
              <!-- make sure to render in local time for the event -->
            <!-- WED, NOV 13 - 7:00 PM GMT -->
              <div class="text-darkblue text-sm md:text-base">
                {Event.format_date(event.starts_at, event.ends_at, event.timezone)}
              </div>
            </div>
          </div>
          <%= if event.description do %>
            <div class="flex flex-col place-content-center text-orangey py-2 px-8 text-justify description line-clamp-2">
              {Event.truncate(event.description)}
            </div>
          <% end %>
          <p class="text-orangey lobster-regular mr-4 place-self-end">
            {String.capitalize(Atom.to_string(event.type))}
          </p>
        </.link>
      <% end %>
      <div class="flex flex-row place-content-center text-orangey text-sm">
        <div class="w-[30px]">
          <%= unless @page == 0 do %>
            <p class="underline cursor-pointer" phx-click="previous_page">Prev</p>
          <% end %>
        </div>
        <p class="px-4">page {@page + 1} of {Enum.count(@pages)}</p>
        <div class="w-[60px]">
          <%= unless @page == (Enum.count(@pages) - 1) do %>
            <p class="underline cursor-pointer" phx-click="next_page">Next</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    pages = Enum.chunk_every(ElixirEvents.Events.front_page(), 10)
    events = Enum.at(pages, 0) || []

    # The event page redirects here with a flash on missing event. To prevent
    # that from sticking around forever it's cleared here.
    Process.send_after(self(), :clear_flash, 3000)

    {:ok,
     assign(socket,
       events: events,
       location_filter: nil,
       page: 0,
       pages: pages,
       page_title: "ElixirEvents"
     )}
  end

  def handle_event("update-options", params, socket) do
    location_filter = params["location"]

    events = filtered_events(location_filter)

    {:noreply, assign(socket, location_filter: location_filter, events: events)}
  end

  def handle_event("next_page", _params, socket) do
    page = socket.assigns.page + 1

    {:noreply, assign(socket, page: page, events: Enum.at(socket.assigns.pages, page))}
  end

  def handle_event("previous_page", _params, socket) do
    page = socket.assigns.page - 1

    {:noreply, assign(socket, page: page, events: Enum.at(socket.assigns.pages, page))}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp options do
    events =
      ElixirEvents.Events.all_future()
      |> Enum.uniq_by(&{&1.country, &1.city})
      |> Enum.sort_by(fn event -> event.country end)

    list =
      for event <- events do
        {"#{event.city}, #{event.country}", "#{event.city}, #{event.country}"}
      end

    [{"All", nil} | list]
  end

  defp filtered_events(filter) when filter in ["", nil] do
    ElixirEvents.Events.front_page()
  end

  defp filtered_events(filter) do
    ElixirEvents.Events.front_page(filter)
  end
end
