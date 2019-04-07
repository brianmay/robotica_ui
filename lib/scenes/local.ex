defmodule RoboticaUi.Scene.Local do
  use Scenic.Scene

  alias Scenic.Graph
  import Scenic.Primitives

  alias RoboticaUi.Components.Nav

  @graph Graph.build(font: :roboto, font_size: 24)
         |> rect({800, 480}, fill: {:red, 0})
         |> Nav.add_to_graph(:local)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    {:ok, %{}, push: @graph}
  end

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end

  def filter_event({:click, _button}, _, state) do
    RoboticaUi.RootManager.reset_screensaver()

    {:halt, state}
  end
end
