defmodule RoboticaUi.Handler do
  use Tortoise.Handler

  alias Scenic.ViewPort

  def init(args) do
    {:ok, args}
  end

  def connection(status, state) do
    # `status` will be either `:up` or `:down`; you can use this to
    # inform the rest of your system if the connection is currently
    # open or closed; tortoise should be busy reconnecting if you get
    # a `:down`
    {:ok, state}
  end

  def handle_message(["stat", "sonoff", "POWER"], "on", state) do
    IO.inspect(state)
    ViewPort.set_root(:main_viewport, {RoboticaUi.Scene.On, nil})
    {:ok, state}
  end

  def handle_message(["stat", "sonoff", "POWER"], "off", state) do
    IO.inspect(state)
    ViewPort.set_root(:main_viewport, {RoboticaUi.Scene.Home, nil})
    {:ok, state}
  end

  def handle_message(topic, payload, state) do
    # unhandled message! You will crash if you subscribe to something
    # and you don't have a 'catch all' matcher; crashing on unexpected
    # messages could be a strategy though.
    {:ok, state}
  end

  def subscription(status, topic_filter, state) do
    {:ok, state}
  end

  def terminate(reason, state) do
    # tortoise doesn't care about what you return from terminate/2,
    # that is in alignment with other behaviours that implement a
    # terminate-callback
    :ok
  end
end
