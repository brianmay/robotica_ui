defmodule RoboticaUi.Scene.Error do
  use Scenic.Scene

  alias Scenic.Graph
  import Scenic.Primitives

  import RoboticaUi.Scene.Utils
  alias RoboticaUi.Components.Nav

  @graph Graph.build(font: :roboto, font_size: 24)
         |> add_status("Error", :red)
         |> Nav.add_to_graph(:lock)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(params, _opts) do
    message = Keyword.get(params, :text)

    @graph
    |> Graph.modify(:text, &text(&1, message || "Error"))
    |> push_graph()

    {:ok, %{}}
  end
end
