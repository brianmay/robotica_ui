defmodule RoboticaUi.Scene.On do
  use Scenic.Scene

  alias Scenic.Graph

  import RoboticaUi.Scene.Utils

  @graph Graph.build(font: :roboto, font_size: 24)
         |> add_button("Off", :btn_enter, 0, 0)
         |> add_status("ON", :green)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    push_graph(@graph)
    {:ok, %{}}
  end

  def filter_event({:click, _}, _, %{}) do
    client_id = RoboticaUi.get_tortoise_client_id()
    Tortoise.publish(client_id, "cmnd/sonoff/power", "off", qos: 0)
    {:stop, %{}}
  end
end
