defmodule RoboticaUi.RoboticaService do
  @moduledoc false

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: RoboticaUi.RoboticaService)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def process(event) do
    GenServer.cast(__MODULE__, event)
  end

  def handle_cast({topic, id}, state) do
    data = EventBus.fetch_event_data({topic, id})

    case data.message.text do
      nil ->
        nil

      text ->
        RoboticaUi.RootManager.set_scene(:message, {RoboticaUi.Scene.Message, text: text})
    end

    EventBus.mark_as_completed({RoboticaService, topic, id})

    Process.sleep(5000)

    RoboticaUi.RootManager.set_scene(:message, nil)
    {:noreply, state}
  end
end
