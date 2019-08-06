defmodule RoboticaUi.Scene.Message do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives

  @graph Graph.build(font: :roboto, font_size: 36)
         |> text("", id: :text, text_align: :center, translate: {400, 240})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(params, _opts) do
    message = Keyword.get(params, :text)

    graph =
      @graph
      |> Graph.modify(:text, &text(&1, message || "Nothing"))

    {:ok, %{}, push: graph}
  end

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end
end
