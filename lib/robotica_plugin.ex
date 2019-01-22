defmodule RoboticaUi.RoboticaPlugin do
  @moduledoc false

  use GenServer
  use Robotica.Plugins.Plugin
  require Logger

  defmodule State do
    @type t :: %__MODULE__{}
    defstruct []
  end

  def init(_opts) do
    {:ok, %State{}}
  end

  def config_schema do
    %{}
  end

  def handle_cast({:execute, action}, state) do
    text =
      case action.message do
        nil -> nil
        msg -> msg.text
      end

    case text do
      nil ->
        nil

      text ->
        RoboticaUi.RootManager.set_scene(:message, {RoboticaUi.Scene.Message, text: text})

        Process.sleep(10000)

        RoboticaUi.RootManager.set_scene(:message, nil)
    end

    {:noreply, state}
  end
end
