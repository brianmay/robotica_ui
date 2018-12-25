defmodule RoboticaUi.RoboticaService do
  @moduledoc false

  use GenServer

  defmodule State do
    @type t :: %__MODULE__{
            message_displayed: boolean()
          }
    defstruct message_displayed: false
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %State{}}
  end

  def process(event) do
    GenServer.cast(__MODULE__, event)
  end

  def handle_cast({:execute = topic, id}, state) do
    data = EventBus.fetch_event_data({topic, id})

    text =
      case data.message do
        nil -> nil
        msg -> msg.text
      end

    state =
      case text do
        nil ->
          state

        text ->
          RoboticaUi.RootManager.set_scene(:message, {RoboticaUi.Scene.Message, text: text})
          %State{state | message_displayed: true}
      end

    EventBus.mark_as_completed({__MODULE__, topic, id})
    {:noreply, state}
  end

  def handle_cast({:done = topic, id}, state) do
    EventBus.fetch_event_data({topic, id})

    if state.message_displayed do
      RoboticaUi.RootManager.set_scene(:message, nil)
    end

    {:noreply, %State{state | message_displayed: false}}
  end
end
