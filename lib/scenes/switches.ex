defmodule RoboticaUi.Scene.Switches do
  use Scenic.Scene
  use EventBus.EventSource

  alias Scenic.Graph
  import Scenic.Primitives

  import RoboticaUi.Scene.Utils
  alias RoboticaUi.Components.Nav

  @graph Graph.build(font: :roboto, font_size: 24)
         |> rect({800, 480}, fill: {:red, 0})
         |> text("Lights", translate: {0 * 100 + 120, 30})
         |> text("Music", translate: {1 * 100 + 120, 30})
         |> add_button("On", :light_on, 0, 0)
         |> add_button("Bed", :Bed1, 0, 1)
         |> add_button("Bed", :Bed2, 0, 2)
         |> add_button("Off", :light_off, 0, 3)
         |> add_button("Red", :red, 1, 0)
         |> add_button("Green", :green, 1, 1)
         |> add_button("Blue", :blue, 1, 2)
         |> add_button("Off", :music_off, 1, 3)
         |> Nav.add_to_graph(:switches)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    push_graph(@graph)
    {:ok, RoboticaUi.Config.configuration()}
  end

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end

  def filter_event({:click, button}, _, state) do
    RoboticaUi.RootManager.reset_screensaver()

    locations = state.locations

    action =
      case button do
        :light_on ->
          %Robotica.Types.Action{
            lights: %{
              action: "turn_on",
              color: %{hue: 0, saturation: 0, brightness: 100, kelvin: 5000}
            }
          }

        :Bed1 ->
          %Robotica.Types.Action{
            lights: %{
              action: "turn_on",
              color: %{hue: 90, saturation: 100, brightness: 6, kelvin: 5000}
            }
          }

        :Bed2 ->
          %Robotica.Types.Action{
            lights: %{
              action: "turn_on",
              color: %{hue: 240, saturation: 50, brightness: 6, kelvin: 5000}
            }
          }

        :light_off ->
          %Robotica.Types.Action{lights: %{action: "turn_off"}}

        :red ->
          %Robotica.Types.Action{music: %{play_list: "red"}}

        :green ->
          %Robotica.Types.Action{music: %{play_list: "green"}}

        :blue ->
          %Robotica.Types.Action{music: %{play_list: "blue"}}

        :music_off ->
          %Robotica.Types.Action{music: %{stop: true}}

        _ ->
          nil
      end

    case action do
      nil -> nil
      _ ->
        event_params = %{topic: :execute}
        EventSource.notify event_params do
          %Robotica.Types.Task{
            locations: locations,
            action: action
          }
        end
    end

    {:stop, state}
  end
end
