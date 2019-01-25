defmodule RoboticaUi.Scene.Switches do
  use Scenic.Scene
  use EventBus.EventSource

  alias Scenic.Graph
  import Scenic.Primitives

  import RoboticaUi.Scene.Utils
  alias RoboticaUi.Components.Nav

  @graph Graph.build(font: :roboto, font_size: 24)
         |> rect({800, 480}, fill: {:red, 0})
         |> add_text("Locations", 0, 0)
         |> add_text("Actions", 0, 1)
         |> add_button("On", {:action, :light_on}, 1, 1)
         |> add_button("Bed", {:action, :Bed1}, 2, 1)
         |> add_button("Bed", {:action, :Bed2}, 3, 1)
         |> add_button("Off", {:action, :light_off}, 4, 1)
         |> add_button("Red", {:action, :red}, 1, 2)
         |> add_button("Green", {:action, :green}, 2, 2)
         |> add_button("Blue", {:action, :blue}, 3, 2)
         |> add_button("Off", {:action, :music_off}, 4, 2)
         |> Nav.add_to_graph(:switches)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    graph = @graph
    configuration = RoboticaUi.Config.configuration()
    all_locations = configuration.locations

    graph = add_text(graph, "Locations", 0, 0)

    {graph, _} =
      Enum.reduce(all_locations, {graph, 0}, fn location, {graph, n} ->
        id_false = {:location, location, false}
        id_true = {:location, location, true}

        graph =
          graph
          |> add_button(location, id_false, n + 1, 0, theme: :primary, hidden: false)
          |> add_button(location, id_true, n + 1, 0, theme: :danger, hidden: true)

        {graph, n + 1}
      end)

    push_graph(graph)

    {:ok, %{locations: MapSet.new(), all_locations: all_locations, graph: graph}}
  end

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end

  def filter_event({:click, button}, _, state) do
    RoboticaUi.RootManager.reset_screensaver()

    state =
      case button do
        {:location, location_button, value} ->
          handle_location_press(location_button, state, value)

        {:action, action_button} ->
          handle_action_press(action_button, state)

        _ ->
          state
      end

    {:stop, state}
  end

  def handle_location_press(location_button, state, value) do
    locations = state.locations
    graph = state.graph

    locations =
      case value do
        true -> MapSet.delete(locations, location_button)
        false -> MapSet.put(locations, location_button)
      end

    graph =
      Enum.reduce(state.all_locations, graph, fn location, graph ->
        value = MapSet.member?(locations, location)

        id_false = {:location, location, false}
        id_true = {:location, location, true}

        graph
        |> Graph.modify(id_false, &update_opts(&1, hidden: value != false))
        |> Graph.modify(id_true, &update_opts(&1, hidden: value != true))
      end)

    push_graph(graph)

    %{state | locations: locations, graph: graph}
  end

  def handle_action_press(action_button, state) do
    action =
      case action_button do
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
      nil ->
        nil

      _ ->
        event_params = %{topic: :execute}

        EventSource.notify event_params do
          %Robotica.Types.Task{
            locations: MapSet.to_list(state.locations),
            action: action
          }
        end
    end

    state
  end
end
