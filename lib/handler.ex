defmodule RoboticaUi.Handler do
  use Tortoise.Handler

  alias Scenic.ViewPort

  def init(_args) do
    {:ok, %{}}
  end

  def connection(:up, state) do
    # Send request for current power level, as we have no idea.
    client_id = RoboticaUi.get_tortoise_client_id()
    Tortoise.publish(client_id, "cmnd/sonoff/power", "", qos: 0)

    # Set loading as viewport root.
    ViewPort.set_root(:main_viewport, {RoboticaUi.Scene.Loading, nil})

    {:ok, state}
  end

  def connection(:down, state) do
    ViewPort.set_root(:main_viewport, {RoboticaUi.Scene.Error, nil})
    {:ok, state}
  end

  def handle_message(["stat", "sonoff", "POWER"], "ON", state) do
    ViewPort.set_root(:main_viewport, {RoboticaUi.Scene.On, nil})
    {:ok, state}
  end

  def handle_message(["stat", "sonoff", "POWER"], "OFF", state) do
    ViewPort.set_root(:main_viewport, {RoboticaUi.Scene.Off, nil})
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
