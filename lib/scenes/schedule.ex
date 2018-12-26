defmodule RoboticaUi.Scene.Schedule do
  use Scenic.Scene
  use EventBus.EventSource
  require Logger

  alias Scenic.Graph
  alias Scenic.ViewPort
  import Scenic.Primitives

  alias RoboticaUi.Components.Nav

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

    {:ok, %{viewport: opts[:viewport]}}
  end

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end

  def date_time_to_local(dt) do
    dt
    |> Calendar.DateTime.shift_zone!("Australia/Melbourne")
    |> Timex.format!("%T", :strftime)
  end

  def filter_event({:schedule, steps}, _, state) do
    # Get the viewport size
    {:ok, %ViewPort.Status{size: {width, _height}}} =
      state[:viewport]
      |> ViewPort.info()

    @graph
    |> group(fn graph ->
      {graph, _} =
        Enum.reduce(steps, {graph, 0}, fn step, {graph, y} ->
          Enum.reduce(step.tasks, {graph, y}, fn task, {graph, y} ->
            text =
              case task.action.message do
                nil -> nil
                msg -> msg.text
              end

            color =
              case task.mark do
                :done -> :green
                :cancelled -> :red
                _ -> :white
              end

            graph =
              graph
              |> text(date_time_to_local(step.required_time), translate: {110, y * 40 + 70}, fill: color)
              |> text(Enum.join(task.locations, ", "), translate: {210, y * 40 + 70}, fill: color)
              |> text(text || "N/A", translate: {410, y * 40 + 70}, fill: color)

            {graph, y + 1}
          end)
        end)

      graph
    end)
    |> line({{110, 40}, {width - 10, 40}}, stroke: {1, :red})
    |> push_graph()

    {:stop, state}
  end
end
