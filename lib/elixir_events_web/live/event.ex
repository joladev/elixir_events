defmodule ElixirEventsWeb.Live.Event do
  @moduledoc """
  LiveView for displaying individual event details.

  Shows comprehensive event information and allows users to submit
  suggestions for corrections or updates to event details.
  """
  use ElixirEventsWeb, :live_view

  alias ElixirEvents.Events.Event
  alias ElixirEvents.Events.Suggestion

  def render(assigns) do
    ~H"""
    <div class="w-[320px] md:w-[424px] place-self-center flex flex-col">
      <div class="pb-2 mb-2.5">
        <.link navigate={~p"/"} class="text-highlight pl-2 pr-4 py-2">
          <.icon name="hero-arrow-left text-highlight h-[24px] w-[24px] -mt-1" /> Back
        </.link>
      </div>
      <div class="border-highlight border-solid border-4 flex flex-col pb-4 pt-4 mb-6 mx-2">
        <div
          class="text-orangey px-2 mr-2 cursor-pointer text-xs place-self-end italic"
          phx-click={show_modal("suggestion")}
        >
          Something wrong?
        </div>
        <div class="flex flex-row">
          <div class="h-16 w-16 md:h-24 md:w-24 p-2 flex flex row place-content-center place-items-center">
            <%= if @event.logo_url do %>
              <img
                class="h-8 w-8 md:h-16 md:w-16"
                alt={"Logo for #{@event.title}"}
                src={@event.logo_url}
              />
            <% else %>
              <.icon class="h-16 w-16 text-highlight" name="hero-photo" />
            <% end %>
          </div>
          <div class="flex flex-col md:h-24 place-content-center">
            <h2 class="text-lg md:text-2xl text-orangey">
              {@event.title}
            </h2>
            <p class="text-lightblue text-sm md:text-base italic">
              <%= if @event.online_only do %>
                Online Only
              <% else %>
                {@event.city}, {@event.country}
              <% end %>
            </p>
            <div class="text-darkblue text-sm md:text-base">
              {Event.format_date(@event.starts_at, @event.ends_at, @event.timezone)}
            </div>
          </div>
        </div>
        <%= if @event.description do %>
          <div class="flex flex-col place-content-center text-orangey py-2 px-8 text-justify description">
            {raw(
              MDEx.to_html!(@event.description, sanitize: MDEx.Document.default_sanitize_options())
            )}
          </div>
        <% end %>
        <div class="flex flex-row place-content-between mt-4">
          <div class="flex flex-row">
            <.link
              class="border rounded-md border-orangey text-orangey px-4 ml-4 py-2"
              href={@event.url}
              target="_blank"
            >
              Go to Event
            </.link>
          </div>
          <p class="text-orangey lobster-regular mr-4 place-self-end">
            {String.capitalize(Atom.to_string(@event.type))}
          </p>
        </div>
      </div>
    </div>
    <.modal id="suggestion" show={@modal_visible}>
      <.header class="text-center">
        Make a Suggestion
        <:subtitle>
          Something about the event incorrect? Information missing or changed?
        </:subtitle>
      </.header>
      <.simple_form
        for={@suggestion_form}
        id="suggestion_form"
        phx-submit="make_suggestion"
        phx-change="validate_suggestion"
      >
        <.input field={@suggestion_form[:description]} type="textarea" label="Description" required />
        <:actions>
          <.button class="border border-highlight" phx-disable-with="Suggesting...">
            Submit
          </.button>
        </:actions>
      </.simple_form>
    </.modal>
    """
  end

  def mount(params, _session, socket) do
    %{"event_id" => event_id, "date" => date} = params

    if event = ElixirEvents.Events.get_by_slug("#{event_id}/#{date}") do
      {:ok,
       assign(socket,
         event: event,
         suggestion_form: to_form(ElixirEvents.Events.change_suggestion(%Suggestion{})),
         modal_visible: false,
         page_title: "ElixirEvents - #{event.title}"
       )}
    else
      {:ok,
       socket
       |> put_flash(:error, "Event not found")
       |> push_navigate(to: ~p"/")}
    end
  end

  def handle_event("validate_suggestion", params, socket) do
    changeset =
      params["suggestion"]
      |> Suggestion.changeset()
      |> Map.put(:action, :insert)

    suggestion_form = to_form(changeset)

    {:noreply, assign(socket, suggestion_form: suggestion_form)}
  end

  def handle_event("make_suggestion", params, socket) do
    attrs = Map.put(params["suggestion"], "event_id", socket.assigns.event.id)

    case ElixirEvents.Events.make_suggestion(attrs) do
      {:ok, _suggestion} ->
        ElixirEvents.Notification.push("suggestion created")

        suggestion_form =
          %Suggestion{}
          |> ElixirEvents.Events.change_suggestion(%{})
          |> to_form()

        {:noreply,
         socket
         |> put_flash(:info, "Suggestion made")
         |> assign(suggestion_form: suggestion_form, modal_visible: false)}

      {:error, changeset} ->
        {:noreply, assign(socket, suggestion_form: to_form(changeset))}
    end
  end
end
