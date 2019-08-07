defmodule RoboticaUi.Scene.Message do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives

  @graph Graph.build(font: :roboto, font_size: 36)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(params, opts) do
    message = Keyword.get(params, :text)

    viewport = opts[:viewport]
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    x = vp_width / 2
    y = vp_height / 2

    graph =
      @graph
      |> rect({vp_width, vp_height}, fill: :black)
      |> text(message, id: :text, text_align: :center, translate: {x, y})

    {:ok, %{}, push: graph}
  end

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end
end
