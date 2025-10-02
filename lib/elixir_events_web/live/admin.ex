defmodule ElixirEventsWeb.Live.Admin do
  @moduledoc """
  Admin panel LiveView for managing events and suggestions.

  Provides functionality to approve/reject events, review event suggestions,
  and edit event details. Restricted to authenticated admin users.
  """
  use ElixirEventsWeb, :live_view

  alias ElixirEvents.Events.Event

  def render(assigns) do
    ~H"""
    <div class="flex flex-col place-content-center align-items-center place-items-center">
      <.table id="events" rows={@events}>
        <:col :let={event} label="id">{event.id}</:col>
        <:col :let={event} label="title">{event.title}</:col>
        <:col :let={event} label="starts_at">{event.starts_at}</:col>
        <:col :let={event} label="location">{event.city}, {event.country}</:col>
        <:col :let={event} label="timezone">{event.timezone}</:col>
        <:col :let={event} label="approved">{emoji(event.approved)}</:col>
        <:col :let={event} label="suggestions">{emoji(all_suggestions_checked(event))}</:col>
        <:action :let={event}>
          <.button phx-click={
            JS.push("load", value: %{id: event.id})
            |> show_modal("edit")
          }>
            Edit
          </.button>
          <.button data-confirm="Are you sure?" phx-click="delete" phx-value-id={event.id}>
            Delete
          </.button>
        </:action>
      </.table>
    </div>

    <.modal id="edit" on_cancel={JS.push("reset")}>
      <%= if @event_form do %>
        <%= if suggestion = Enum.find(@event.suggestions, &  &1.checked == false) do %>
          <p class="text-orangey text-lg">Suggestions</p>
          <p class="text-white border border-highlight p-2">{suggestion.description}</p>
          <button
            phx-value-id={suggestion.id}
            phx-click="check_suggestion"
            class="text-white border border-highlight rounded-md px-4 py-2 mt-2"
          >
            Check
          </button>
        <% end %>

        <h2 class="text-white">Bluesky Preview</h2>
        <div class="bg-white">
          {raw(
            MDEx.to_html!(ElixirEvents.Bluesky.text(@event),
              sanitize: MDEx.Document.default_sanitize_options()
            )
          )}
        </div>
        <.button class="button border border-highlight" phx-click="post">Post to Bluesky</.button>

        <.simple_form
          for={@event_form}
          id="event_form"
          phx-submit="edit_event"
          phx-change="validate_event"
        >
          <.input field={@event_form[:title]} type="text" label="Title" required />
          <.input field={@event_form[:slug]} type="text" label="Slug" required />
          <.input
            field={@event_form[:type]}
            type="select"
            options={[{"Conference", :conference}, {"Meetup", :meetup}]}
            label="Type"
            required
          />
          <.input field={@event_form[:url]} type="url" label="Link to Event" required />
          <.input field={@event_form[:logo_url]} type="url" label="Link to Logo" />
          <.input field={@event_form[:online_only]} type="checkbox" label="Online Only" />
          <%= unless @event_form[:online_only].value do %>
            <.input field={@event_form[:city]} type="text" label="City" required />
            <.input field={@event_form[:country]} type="text" label="Country" required />
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
          <.input field={@event_form[:timezone]} type="text" label="Timezone" required />
          <.input field={@event_form[:description]} type="textarea" label="Description" />
          <.input field={@event_form[:approved]} type="checkbox" label="Approved" />
          <:actions>
            <.button class="border border-highlight" phx-disable-with="Changing...">
              Submit
            </.button>
          </:actions>
        </.simple_form>
      <% end %>
    </.modal>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       events: ElixirEvents.Events.admin_page(),
       event_form: nil,
       event: nil
     )}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, event_form: nil, event: nil)}
  end

  def handle_event("load", params, socket) do
    event = ElixirEvents.Events.get_with_unchecked_suggestions(params["id"])
    changeset = ElixirEvents.Events.change(event)
    event_form = to_form(changeset)

    {:noreply, assign(socket, event_form: event_form, event: event)}
  end

  def handle_event("validate_event", params, socket) do
    changeset =
      params["event"]
      |> Event.changeset()
      |> Map.put(:action, :insert)

    event_form = to_form(changeset)

    {:noreply, assign(socket, event_form: event_form)}
  end

  def handle_event("edit_event", params, socket) do
    case ElixirEvents.Events.update(socket.assigns.event, params["event"]) do
      {:ok, event} ->
        event_form =
          event
          |> ElixirEvents.Events.change(%{})
          |> to_form()

        {:noreply,
         socket
         |> put_flash(:info, "Updated")
         |> assign(
           event_form: event_form,
           events: ElixirEvents.Events.admin_page()
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, event_form: to_form(changeset))}
    end
  end

  def handle_event("delete", params, socket) do
    id = params["id"]

    case ElixirEvents.Events.delete(id) do
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, "Deleted")
         |> assign(events: ElixirEvents.Events.admin_page())}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "No such event")}
    end
  end

  def handle_event("check_suggestion", %{"id" => id}, socket) do
    ElixirEvents.Events.check_suggestion!(id)
    event = ElixirEvents.Events.get_with_unchecked_suggestions(socket.assigns.event.id)

    {:noreply,
     socket
     |> put_flash(:info, "Checked")
     |> assign(event: event)}
  end

  def handle_event("post", _params, socket) do
    case ElixirEvents.Bluesky.post(socket.assigns.event) do
      {:ok, result} ->
        case result.status do
          200 ->
            {:noreply, put_flash(socket, :info, "Posted")}

          _ ->
            {:noreply, put_flash(socket, :error, inspect(result.body))}
        end

      {:error, error} ->
        {:noreply, put_flash(socket, :error, inspect(error))}
    end
  end

  defp emoji(true) do
    "✅"
  end

  defp emoji(false) do
    "⚠️"
  end

  defp all_suggestions_checked(event) do
    Enum.all?(event.suggestions, & &1.checked)
  end
end
