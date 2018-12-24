defmodule RoboticaUi.Scene.Message do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives
  import RoboticaUi.Scene.Utils

  @graph Graph.build(font: :roboto, font_size: 24)
         |> add_status("", :red)

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
