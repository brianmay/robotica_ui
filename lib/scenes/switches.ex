defmodule RoboticaUi.Scene.Switches do
  use Scenic.Scene

  alias Scenic.Graph
  import Scenic.Primitives

  import RoboticaUi.Scene.Utils
  alias RoboticaUi.Components.Nav

  @graph Graph.build(font: :roboto, font_size: 24)
         |> rect({800, 480}, fill: {:red, 0})
         |> text("Brian", translate: {0 * 100 + 120, 30})
         |> text("Twins", translate: {1 * 100 + 120, 30})
         |> text("Dining", translate: {2 * 100 + 120, 30})
         |> text("Akira", translate: {3 * 100 + 120, 30})
         |> add_button("On", {:BM, :On}, 0, 0)
         |> add_button("On", {:T, :On}, 1, 0)
         |> add_button("On", {:D, :On}, 2, 0)
         |> add_button("On", {:A, :On}, 3, 0)
         |> add_button("M1", {:all, :M1}, 4, 0)
         |> add_button("Bed", {:BM, :Bed1}, 0, 1)
         |> add_button("Bed", {:T, :Bed1}, 1, 1)
         |> add_button("Bed", {:D, :Bed1}, 2, 1)
         |> add_button("Bed", {:A, :On}, 3, 1)
         |> add_button("M2", {:all, :M2}, 4, 1)
         |> add_button("Bed", {:BM, :Bed2}, 0, 2)
         |> add_button("Bed", {:T, :Bed2}, 1, 2)
         |> add_button("Bed", {:D, :Bed2}, 2, 2)
         |> add_button("Bed", {:A, :Bed2}, 3, 2)
         |> add_button("M3", {:all, :M3}, 4, 2)
         |> add_button("Off", {:BM, :Off}, 0, 3)
         |> add_button("Off", {:T, :Off}, 1, 3)
         |> add_button("Off", {:D, :Off}, 2, 3)
         |> add_button("Off", {:A, :Off}, 3, 3)
         |> add_button("M4", {:all, :M4}, 4, 3)
         |> Nav.add_to_graph(:switches)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    push_graph(@graph)
    {:ok, %{}}
  end

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end

  def filter_event({:click, button}, _, state) do
    RoboticaUi.RootManager.reset_screensaver()

    locations =
      case button do
        {:BM, _} -> ["Brian"]
        {:T, _} -> ["Twins"]
        {:D, _} -> ["Dining"]
        {:A, _} -> ["Akira"]
        {:all, _} -> ["Brian", "Twins", "Dining", "Akira"]
      end

    action =
      case button do
        {_, :M1} ->
          %{message: %{text: "Test only, do not listen."}}

        {_, :M2} ->
          %{message: %{text: "It is time for Brian to clean his teeth."}}

        {_, :M3} ->
          %{message: %{text: "Tilly is a cat."}}

        {_, :M4} ->
          %{message: %{text: "Meow Meow meow."}}

        {_, :On} ->
          %{
            lights: %{
              action: "turn_on",
              color: %{hue: 0, saturation: 0, brightness: 100, kelvin: 5000}
            }
          }

        {_, :Bed1} ->
          %{
            lights: %{
              action: "turn_on",
              color: %{hue: 90, saturation: 100, brightness: 6, kelvin: 5000}
            }
          }

        {_, :Bed2} ->
          %{
            lights: %{
              action: "turn_on",
              color: %{hue: 240, saturation: 50, brightness: 6, kelvin: 5000}
            }
          }

        {_, :Off} ->
          %{lights: %{action: "turn_off"}}

        _ ->
          nil
      end

    case action do
      nil -> nil
      _ -> RoboticaUi.Mqtt.publish_execute(locations, action)
    end

    {:stop, state}
  end
end
