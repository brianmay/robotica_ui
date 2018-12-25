defmodule RoboticaUi.Scene.Off do
  use Scenic.Scene

  alias Scenic.Graph
  import Scenic.Primitives

  import RoboticaUi.Scene.Utils
  alias RoboticaUi.Components.Nav

  @graph Graph.build(font: :roboto, font_size: 24)
         |> rect({800, 480}, fill: {:red, 0})
         |> add_button("C", :btn_clear, 0, 3)
         |> add_button("0", "0", 1, 3)
         |> add_button("E", :btn_enter, 2, 3)
         |> add_button("1", "1", 0, 2)
         |> add_button("2", "2", 1, 2)
         |> add_button("3", "3", 2, 2)
         |> add_button("4", "4", 0, 1)
         |> add_button("5", "5", 1, 1)
         |> add_button("6", "6", 2, 1)
         |> add_button("7", "7", 0, 0)
         |> add_button("8", "8", 1, 0)
         |> add_button("9", "9", 2, 0)
         |> add_status("OFF", :green)
         |> Nav.add_to_graph(:lock)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    push_graph(@graph)
    {:ok, %{password: ""}}
  end

  def filter_event({:click, button}, _, %{password: password}) do
    RoboticaUi.RootManager.reset_screensaver()

    ok =
      case button do
        :btn_enter -> password == "1234"
        _ -> nil
      end

    password =
      case button do
        :btn_clear -> ""
        :btn_enter -> ""
        x -> password <> x
      end

    {message, style} =
      case ok do
        true -> {"Good", fill: :green}
        false -> {"Bad", fill: :red}
        nil -> {"OFF", []}
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

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end
end
