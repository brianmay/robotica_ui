defmodule RoboticaUi.RoboticaService do
  @moduledoc false

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def process(event) do
    GenServer.cast(__MODULE__, event)
  end

  def handle_cast({:execute = topic, id}, state) do
    data = EventBus.fetch_event_data({topic, id})

    case data.message.text do
      nil ->
        nil

      text ->
        RoboticaUi.RootManager.set_scene(:message, {RoboticaUi.Scene.Message, text: text})
    end

    EventBus.mark_as_completed({__MODULE__, topic, id})

    #    Process.sleep(500)

    {:noreply, state}
  end

  def handle_cast({:done = topic, id}, state) do
    EventBus.fetch_event_data({topic, id})
    RoboticaUi.RootManager.set_scene(:message, nil)
    {:noreply, state}
  end
end
