defmodule RoboticaUi.Scene.Off do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives
  import Scenic.Components

  @graph Graph.build(font: :roboto, font_size: 24)
         |> button("C", id: :btn_clear, translate: {20, 200})
         |> button("0", id: "0", translate: {120, 200})
         |> button("E", id: :btn_enter, translate: {220, 200})
         |> button("1", id: "1", translate: {20, 150})
         |> button("2", id: "2", translate: {120, 150})
         |> button("3", id: "3", translate: {220, 150})
         |> button("4", id: "4", translate: {20, 100})
         |> button("5", id: "5", translate: {120, 100})
         |> button("6", id: "6", translate: {220, 100})
         |> button("7", id: "7", translate: {20, 50})
         |> button("8", id: "8", translate: {120, 50})
         |> button("9", id: "9", translate: {220, 50})
         |> text("OFF", id: :text, text_align: :center, translate: {160, 400})
         |> circle(100, stroke: {2, :green}, translate: {160, 400})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    push_graph(@graph)
    {:ok, %{password: ""}}
  end

  def filter_event({:click, button}, _, %{password: password}) do
    ok =
      case button do
        :btn_enter -> password == "1234"
        _ -> nil
      end

    password =
      case button do
        :btn_clear -> "OFF"
        :btn_enter -> "OFF"
        x -> password <> x
      end

    {message, style} =
      case ok do
        true -> {"Good", fill: :green}
        false -> {"Bad", fill: :red}
        nil -> {"nil", []}
      end

    @graph
    |> Graph.modify(:text, &text(&1, message, style))
    |> push_graph()

    if ok == true do
      client_id = RoboticaUi.get_tortoise_client_id()
      Tortoise.publish(client_id, "cmnd/sonoff/power", "on", qos: 0)
    end

    {:stop, %{password: password}}
  end
end
