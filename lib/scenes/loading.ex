defmodule RoboticaUi.Scene.Loading do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives

  @graph Graph.build(font: :roboto, font_size: 36)
         |> text("Loading...", id: :text, text_align: :center, translate: {400, 240})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_params, _opts) do
    {:ok, %{}}
  end
end
