defmodule RoboticaUi.Scene.Loading do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives

  @graph Graph.build(font: :roboto, font_size: 36)
         |> rect({800, 480}, fill: {:red, 0})
         |> text("Loading...", id: :text, text_align: :center, translate: {400, 240})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_params, _opts) do
    @graph
    |> push_graph()

    {:ok, %{}}
  end

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end
end
