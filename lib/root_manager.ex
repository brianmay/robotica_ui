defmodule RoboticaUi.RootManager do
  @moduledoc false
  require Logger

  use GenServer

  alias Scenic.ViewPort

  defmodule Scenes do
    @type t :: %__MODULE__{
            root: atom() | {atom(), any()} | nil,
            message: atom() | {atom(), any()} | nil
          }
    defstruct [:root, :message]
  end

  defmodule State do
    @type t :: %__MODULE__{
            scenes: Scenes.t(),
            timer: reference() | nil
          }
    defstruct scenes: %Scenes{}, timer: nil
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, %State{}}
  end

  @spec set_scene(String.t(), atom() | {atom(), any()} | nil) :: nil
  def set_scene(id, scene) do
    GenServer.call(RoboticaUi.RootManager, {:set_scene, id, scene})
  end

  @spec reset_screensaver :: nil
  def reset_screensaver() do
    GenServer.call(RoboticaUi.RootManager, {:reset_screensaver})
  end

  @spec set_root(State.t()) :: nil
  defp set_root(%State{} = state) do
    root_scene =
      cond do
        not is_nil(state.scenes.message) -> state.scenes.message
        true -> state.scenes.root
      end

    ViewPort.set_root(:main_viewport, root_scene)
  end

  defp screen_off() do
    Logger.debug("screen_off")
    File.write!("/sys/class/backlight/rpi_backlight/bl_power", "1")
    System.cmd("vcgencmd", ["display_power", "0"])
    ViewPort.set_root(:main_viewport, {RoboticaUi.Scene.Screensaver, nil})
  end

  defp screen_on() do
    Logger.debug("screen_on")
    File.write!("/sys/class/backlight/rpi_backlight/bl_power", "0")
    System.cmd("vcgencmd", ["display_power", "1"])
  end

  defp reset_timer(state, set_root) do
    Logger.info("reset_timer")

    cond do
      is_nil(state.timer) ->
        # Screen is off.
        set_root(state)
        screen_on()

      set_root ->
        # Screen is on, but we want to update the root.
        set_root(state)

      true ->
        # None of the above.
        nil
    end

    # Reset the timer
    if not is_nil(state.timer) do
      Process.cancel_timer(state.timer)
    end

    timer = Process.send_after(__MODULE__, :screen_off, 30000, [])

    %State{state | timer: timer}
  end

  defp blank_now(state) do
    Logger.info("blank_now")

    if not is_nil(state.timer) do
      # Screen is on
      Process.cancel_timer(state.timer)
      screen_off()
    end

    # Delete the timer.
    timer = nil
    %State{state | timer: timer}
  end

  @impl true
  def handle_info(:screen_off, state) do
    state = blank_now(state)
    {:noreply, state}
  end

  @impl true
  def handle_call({:set_scene, id, scene}, _from, state) do
    Logger.info("set_scene")
    state = %State{state | scenes: %{state.scenes | id => scene}}
    state = reset_timer(state, true)
    set_root(state)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:reset_screensaver}, _from, state) do
    Logger.info("reset_screensaver")
    state = reset_timer(state, false)
    {:reply, :ok, state}
  end
end
