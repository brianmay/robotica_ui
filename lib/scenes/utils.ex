defmodule RoboticaUi.Scene.Utils do
  import Scenic.Components
  import Scenic.Primitives

  def add_button(graph, label, id, x, y) do
    x = x * 100 + 120
    y = y * 100 + 50

    button(graph, label, id: id, translate: {x, y}, width: 80, height: 80)
  end

  def add_status(graph, text, color) do
    graph
    |> text(text, id: :text, text_align: :center, translate: {600, 240})
    |> circle(100, stroke: {2, color}, translate: {600, 240})
  end
end
