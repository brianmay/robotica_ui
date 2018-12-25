defmodule RoboticaUi.Scene.Switches do
  use Scenic.Scene

  alias Scenic.Graph
  import Scenic.Primitives

  alias RoboticaUi.Components.Nav

  @graph Graph.build(font: :roboto, font_size: 24)
         |> rect({800, 480}, fill: :black)
         |> Nav.add_to_graph(:switches)

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
