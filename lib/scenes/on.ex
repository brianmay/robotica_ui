defmodule RoboticaUi.Scene.On do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives
  import Scenic.Components

  @graph Graph.build(font: :roboto, font_size: 24)
  |> button("Turn Off TV", id: :btn_enter, translate: {20, 20}, width: 200)
  |> text("OFF", id: :text, text_align: :center, translate: {160, 400})
  |> circle(100, stroke: {2, :green}, translate: {160, 400})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    push_graph( @graph )
    {:ok, %{}}
  end

  def filter_event({:click, _}, _, %{}) do
    client_id = RoboticaUi.get_tortoise_client_id()
    Tortoise.publish(client_id, "cmnd/sonoff/power", "off", qos: 0)
    {:stop, %{}}
  end
end
