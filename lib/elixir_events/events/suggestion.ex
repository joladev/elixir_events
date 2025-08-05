defmodule ElixirEvents.Events.Suggestion do
  @moduledoc """
  Ecto schema for event suggestions.

  Represents user-submitted corrections or updates to existing events
  that require admin review before being applied.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirEvents.Events.Event

  schema "suggestions" do
    field :description, :string
    field :checked, :boolean

    belongs_to :event, Event

    timestamps(type: :utc_datetime)
  end

  def changeset(params) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(event, params) do
    event
    |> cast(params, [
      :description,
      :event_id
    ])
    |> validate_required([:description, :event_id])
  end
end
