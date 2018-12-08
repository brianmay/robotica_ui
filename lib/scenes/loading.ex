defmodule RoboticaUi.Scene.Loading do
  use Scenic.Scene

  alias Scenic.Graph

  import RoboticaUi.Scene.Utils

  @graph Graph.build(font: :roboto, font_size: 24)
         |> add_status("Loading...", :red)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    push_graph(@graph)
    {:ok, %{}}
  end
end
