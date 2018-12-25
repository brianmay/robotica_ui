defmodule RoboticaUi.Handler do
  use Tortoise.Handler

  def init(_args) do
    {:ok, %{}}
  end

  def connection(:up, state) do
    # Send request for current power level, as we have no idea.
    client_id = RoboticaUi.get_tortoise_client_id()
    Tortoise.publish(client_id, "cmnd/sonoff/power", "", qos: 0)

    # Set loading as viewport root.
    RoboticaUi.RootManager.set_tab_scene(:lock, {RoboticaUi.Scene.Error, text: "Loading"})
    {:ok, state}
  end

  def connection(:down, state) do
    RoboticaUi.RootManager.set_tab_scene(:lock, {RoboticaUi.Scene.Error, text: "MQTT server down"})
    {:ok, state}
  end

  def connection(:terminated, state) do
    RoboticaUi.RootManager.set_tab_scene(:lock, {RoboticaUi.Scene.Error, text: "MQTT server terminated"})
    {:ok, state}
  end

  def handle_message(["stat", "sonoff", "POWER"], "ON", state) do
    RoboticaUi.RootManager.set_tab_scene(:lock, {RoboticaUi.Scene.On, nil})
    {:ok, state}
  end

  def handle_message(["stat", "sonoff", "POWER"], "OFF", state) do
    RoboticaUi.RootManager.set_tab_scene(:lock, {RoboticaUi.Scene.Off, nil})
    {:ok, state}
  end

  def handle_message(_topic, _payload, state) do
    # unhandled message! You will crash if you subscribe to something
    # and you don't have a 'catch all' matcher; crashing on unexpected
    # messages could be a strategy though.
    {:ok, state}
  end

  def subscription(_status, _topic_filter, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    # tortoise doesn't care about what you return from terminate/2,
    # that is in alignment with other behaviours that implement a
    # terminate-callback
    :ok
  end
end
