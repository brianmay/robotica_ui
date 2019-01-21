defmodule RoboticaUi.Components.Task do
  @moduledoc false

  use Scenic.Component

  alias Scenic.Graph
  import Scenic.Primitives

  def verify(step), do: {:ok, step}

  @graph Graph.build(styles: %{}, font_size: 20)

  defp date_time_to_local(dt) do
    dt
    |> Calendar.DateTime.shift_zone!("Australia/Melbourne")
    |> Timex.format!("%T", :strftime)
  end

  def init(step, opts) do
    width = opts[:styles][:width]
    task = hd(step.tasks)

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

    @graph
    |> rect({width, 40}, fill: {:green, 0}, translate: {0, 0})
    |> text(date_time_to_local(step.required_time), translate: {10, 30}, fill: color)
    |> text(Enum.join(task.locations, ", "), translate: {110, 30}, fill: color)
    |> text(text || "N/A", translate: {310, 30}, fill: color)
    |> push_graph()

    {:ok, %{step: step}}
  end

  def handle_input({:cursor_button, {:left, :press, 0, _click_pos}}, _context, state) do
    send_event({:click, state.step})

    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end

  def handle_input(_event, _context, state) do
    RoboticaUi.RootManager.reset_screensaver()
    {:noreply, state}
  end
end