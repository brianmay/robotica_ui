defmodule RoboticaUi.Scene.Message do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives

  @graph Graph.build(font: :roboto, font_size: 24)
         |> text("", id: :text, text_align: :center, translate: {400, 240})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(params, _opts) do
    message = Keyword.get(params, :text)

    @graph
    |> Graph.modify(:text, &text(&1, message || "Nothing"))
    |> push_graph()

    {:ok, %{}}
  end
end
