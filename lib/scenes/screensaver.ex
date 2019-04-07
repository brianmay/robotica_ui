defmodule RoboticaUi.Scene.Screensaver do
  use Scenic.Scene

  require Logger

  alias Scenic.Graph
  import Scenic.Primitives

  @graph Graph.build(font: :roboto, font_size: 24)
         |> rect({800, 480}, fill: :black)
         |> text("The screen is off", id: :text, text_align: :center, translate: {400, 240})

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
end
