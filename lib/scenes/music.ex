defmodule RoboticaUi.Scene.Music do
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
         |> add_button("Red", {:BM, :red}, 0, 0)
         |> add_button("Red", {:T, :red}, 1, 0)
         |> add_button("Red", {:D, :red}, 2, 0)
         |> add_button("Red", {:A, :red}, 3, 0)
         |> add_button("Green", {:BM, :green}, 0, 1)
         |> add_button("Green", {:T, :green}, 1, 1)
         |> add_button("Green", {:D, :green}, 2, 1)
         |> add_button("Green", {:A, :green}, 3, 1)
         |> add_button("Blue", {:BM, :blue}, 0, 2)
         |> add_button("Blue", {:T, :blue}, 1, 2)
         |> add_button("Blue", {:D, :blue}, 2, 2)
         |> add_button("Blue", {:A, :blue}, 3, 2)
         |> add_button("Off", {:BM, :off}, 0, 3)
         |> add_button("Off", {:T, :off}, 1, 3)
         |> add_button("Off", {:D, :off}, 2, 3)
         |> add_button("Off", {:A, :off}, 3, 3)
         |> Nav.add_to_graph(:music)

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
        {_, :red} ->
          %{music: %{play_list: "red"}}

        {_, :green} ->
          %{music: %{play_list: "green"}}

        {_, :blue} ->
          %{music: %{play_list: "blue"}}

        {_, :off} ->
          %{music: %{stop: true}}

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
