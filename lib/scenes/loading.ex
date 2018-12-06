defmodule RoboticaUi.Scene.Loading do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives

  @graph Graph.build(font: :roboto, font_size: 24)
  |> text("LOADING", fill: :red, text_align: :center, translate: {160, 400})
  |> circle(100, stroke: {2, :red}, translate: {160, 400})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    push_graph( @graph )
    {:ok, %{}}
  end
end
