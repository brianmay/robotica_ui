defmodule RoboticaUi.Scene.Schedule do
  use Scenic.Scene
  use EventBus.EventSource
  require Logger

  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives

  alias RoboticaUi.Components.Nav
  alias RoboticaUi.Components.Task
  alias RoboticaUi.Components.Marks

  @graph Graph.build(font: :roboto, font_size: 24)
         |> rect({800, 480}, fill: {:red, 0})
         |> Nav.add_to_graph(:schedule)
         |> text("Time", text_align: :left, translate: {110, 30})
         |> text("Locations", text_align: :left, translate: {210, 30})
         |> text("Message", text_align: :left, translate: {410, 30})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, opts) do
    push_graph(@graph)
    RoboticaUi.RoboticaService.register(self())

    event_params = %{topic: :request_schedule}

    EventSource.notify event_params do
      nil
    end

    viewport = opts[:viewport]

    # Get the viewport size
    {:ok, %ViewPort.Status{size: {width, height}}} =
      viewport
      |> ViewPort.info()

    {:ok, %{graph: @graph, width: width, height: height}}
  end

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end

  def filter_event({:schedule, steps}, _, state) do
    width = state.width

    graph =
      @graph
      |> group(fn graph ->
        {graph, _} =
          Enum.reduce(steps, {graph, 0}, fn step, {graph, y} ->
            Enum.reduce(step.tasks, {graph, y}, fn task, {graph, y} ->
              solo_step = %{step | tasks: [task]}

              graph =
                graph
                |> Task.add_to_graph(solo_step, translate: {100, y * 40 + 40}, width: width - 100)

              {graph, y + 1}
            end)
          end)

        graph
      end)
      |> line({{110, 40}, {width - 10, 40}}, stroke: {1, :red})
      |> push_graph()

    {:stop, %{state | graph: graph}}
  end

  def filter_event({:click, step}, _, state) do
    state.graph
    |> Marks.add_to_graph(step,
      translate: {10, 10},
      width: state.width - 20,
      height: state.height - 20
    )
    |> push_graph()

    {:stop, state}
  end

  def filter_event({:done, _step}, _, state) do
    state.graph
    |> push_graph()

    {:stop, state}
  end
end
