defmodule RoboticaUi.Scene.Screensaver do
  use Scenic.Scene

  require Logger

  alias Scenic.Graph
  import Scenic.Primitives

  @graph Graph.build(font: :roboto, font_size: 24)
         |> rect({800, 480}, fill: :black)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    push_graph(@graph)
    {:ok, %{}}
  end

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end
end
