defmodule ElixirEventsWeb.Live.Propose do
  @moduledoc """
  LiveView for proposing new events to the system.

  Allows users to submit new events which will be reviewed by admins
  before being published. Includes form validation and submission handling.
  """
  use ElixirEventsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="w-[320px] md:w-[424px] place-self-center">
      <%= if @disabled do %>
        <p class="text-orangey">Adding new events is disabled at the moment.</p>
      <% else %>
        <.header class="text-center">
          Propose an Event
          <:subtitle>
            Events are only published once approved.
          </:subtitle>
        </.header>
        <div>
          <.simple_form
            for={@event_form}
            id="event_form"
            phx-submit="register_event"
            phx-change="validate_event"
          >
            <.input
              field={@event_form[:title]}
              type="text"
              label="Title"
              required
              placeholder="ElixirConf"
            />
            <.input
              field={@event_form[:type]}
              type="select"
              label="Type"
              options={[{"Conference", :conference}, {"Meetup", :meetup}]}
              required
            />
            <.input
              field={@event_form[:url]}
              type="url"
              label="Link to Event"
              required
              placeholder="https://elixirconf.com"
            />
            <.input field={@event_form[:logo_url]} type="url" label="Link to Logo (optional)" />
            <.input field={@event_form[:online_only]} type="checkbox" label="Online Only" />
            <%= unless @event_form[:online_only].value do %>
              <.input
                field={@event_form[:city]}
                type="text"
                label="City"
                required
                placeholder="Stockholm"
              />
              <.input
                field={@event_form[:country]}
                type="text"
                label="Country"
                required
                placeholder="Sweden"
              />
            <% end %>
            <.input
              field={@event_form[:starts_at]}
              type="datetime-local"
              label="Starts At"
              required
              min={Date.utc_today()}
              max={Date.add(Date.utc_today(), 600)}
            />
            <.input
              field={@event_form[:ends_at]}
              type="datetime-local"
              label="Ends At"
              required
              min={Date.utc_today()}
              max={Date.add(Date.utc_today(), 600)}
            />
            <.input
              field={@event_form[:timezone]}
              type="text"
              label="Timezone"
              required
              list={TzExtra.time_zone_ids()}
              placeholder="Europe/Berlin"
            />
            <.input field={@event_form[:description]} type="textarea" label="Description (optional)" />
            <:actions>
              <.button class="border border-highlight" phx-disable-with="Changing...">
                Propose
              </.button>
            </:actions>
          </.simple_form>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    event_changeset = ElixirEvents.Events.change(%ElixirEvents.Events.Event{})
    disabled = FunWithFlags.enabled?(:disable_propose)

    # Get IP address during mount when connect_info is available
    ip_address = ElixirEvents.RateLimit.get_ip_address(socket)

    {:ok,
     assign(socket,
       event_form: to_form(event_changeset),
       disabled: disabled,
       page_title: "ElixirEvents - Propose New Event",
       ip_address: ip_address
     )}
  end

  def handle_event("validate_event", params, socket) do
    event_form =
      %ElixirEvents.Events.Event{}
      |> ElixirEvents.Events.change(params["event"])
      |> to_form(action: :validate)

    {:noreply, assign(socket, event_form: event_form)}
  end

  def handle_event("register_event", params, socket) do
    # Check rate limit using IP address from assigns
    case ElixirEvents.RateLimit.check_event_proposal(socket.assigns.ip_address) do
      {:allow, _count} ->
        # Proceed with event registration
        case ElixirEvents.Events.register_event(params["event"]) do
          {:error, changeset} ->
            Sentry.capture_message("invalid changeset", extra: %{errors: changeset.errors})

            {:noreply, assign(socket, event_form: to_form(Map.put(changeset, :action, :insert)))}

          {:ok, _event} ->
            ElixirEvents.Notification.push("event created")

            socket =
              socket
              |> put_flash(:info, "Event created")
              |> push_navigate(to: ~p"/")

            {:noreply, socket}
        end

      {:deny, _limit} ->
        # Rate limited
        socket =
          put_flash(socket, :error, "You've submitted too many events. Please try again later.")

        {:noreply, socket}
    end
  end
end
