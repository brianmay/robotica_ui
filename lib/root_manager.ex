defmodule RoboticaUi.RootManager do
  @moduledoc false
  require Logger

  use GenServer

  alias Scenic.ViewPort

  defmodule Scenes do
    @type t :: %__MODULE__{
            message: atom() | {atom(), any()} | nil
          }
    defstruct [:message]
  end

  defmodule Tabs do
    @type t :: %__MODULE__{
                 schedule: atom() | {atom(), any()} | nil,
                 lock: atom() | {atom(), any()} | nil,
                 switches: atom() | {atom(), any()} | nil
               }
    defstruct [:schedule, :lock, :switches]
  end

  defmodule State do
    @type t :: %__MODULE__{
            scenes: Scenes.t(),
            tabs: Tabs.t(),
            tab: :schedule | :lock,
            timer: reference() | nil,
            scene: atom() | {atom(), any()} | nil
          }
    defstruct scenes: %Scenes{}, tabs:  %Tabs{
        schedule: {RoboticaUi.Scene.Schedule, nil},
        lock: {RoboticaUi.Scene.Loading, nil},
        switches: {RoboticaUi.Scene.Switches, nil}
      }, tab: :schedule, timer: nil, scene: nil
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, %State{}}
  end

  @spec set_scene(:message, atom() | {atom(), any()} | nil) :: nil
  def set_scene(id, scene) do
    GenServer.call(RoboticaUi.RootManager, {:set_scene, id, scene})
  end

  @spec set_tab_scene(:schedule | :lock | :switches, atom() | {atom(), any()} | nil) :: nil
  def set_tab_scene(id, scene) do
    GenServer.call(RoboticaUi.RootManager, {:set_tab_scene, id, scene})
  end

  @spec set_tab(:schedule | :lock | :switches) :: nil
  def set_tab(id) do
    GenServer.call(RoboticaUi.RootManager, {:set_tab, id})
  end

  @spec reset_screensaver :: nil
  def reset_screensaver() do
    GenServer.call(RoboticaUi.RootManager, {:reset_screensaver})
  end

  @spec set_root(State.t()) :: {:changed | :not_changed, State.t()}
  defp set_root(%State{} = state) do

    root_scene =
      cond do
        not is_nil(state.scenes.message) -> state.scenes.message
        true -> Map.get(state.tabs, state.tab)
      end

    current_scene = state.scene

    do_change = root_scene != current_scene
    Logger.info("set_root #{inspect(do_change)} #{inspect(root_scene)} #{inspect(current_scene)}")

    case do_change do
      true ->
        ViewPort.set_root(:main_viewport, root_scene)
        {:changed, %State{state | scene: root_scene}}

      false ->
        {:not_changed, state}
    end
  end

  @spec screen_off :: nil
  defp screen_off() do
    Logger.debug("screen_off")
    File.write!("/sys/class/backlight/rpi_backlight/bl_power", "1")
    System.cmd("vcgencmd", ["display_power", "0"])
    ViewPort.set_root(:main_viewport, {RoboticaUi.Scene.Screensaver, nil})
  end

  @spec screen_on :: nil
  defp screen_on() do
    Logger.debug("screen_on")
    File.write!("/sys/class/backlight/rpi_backlight/bl_power", "0")
    System.cmd("vcgencmd", ["display_power", "1"])
  end

  @spec reset_timer(State.t()) :: State.t()
  defp reset_timer(state) do
    Logger.info("reset_timer")

    case state.timer do
      nil ->
        # Screen is off.
        screen_on()

      _ ->
        # Screen is on.
        Process.cancel_timer(state.timer)
    end

    timer = Process.send_after(__MODULE__, :screen_off, 30000, [])
    %State{state | timer: timer}
  end

  @spec set_root_and_reset_timer(State.t()) :: State.t()
  def set_root_and_reset_timer(state) do
    {changed, state} = set_root(state)

    case changed do
      :changed -> reset_timer(state)
      :not_changed -> state
    end
  end

  @spec blank_now(State.t()) :: State.t()
  defp blank_now(state) do
    Logger.info("blank_now")

    if not is_nil(state.timer) do
      # Screen is on
      Process.cancel_timer(state.timer)
      screen_off()
    end

    # Delete the timer and the current scene.
    %State{state | timer: nil, scene: nil}
  end

  @impl true
  def handle_info(:screen_off, state) do
    state = blank_now(state)
    {:noreply, state}
  end

  @impl true
  def handle_call({:set_scene, id, scene}, _from, state) do
    Logger.info("set_scene #{inspect(id)} #{inspect(scene)}")
    state = %State{state | scenes: %{state.scenes | id => scene}}
    state = set_root_and_reset_timer(state)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:set_tab_scene, id, scene}, _from, state) do
    Logger.info("set_tab_scene #{inspect(id)} #{inspect(scene)}")
    state = %State{state | tabs: %{state.tabs | id => scene}}
    state = set_root_and_reset_timer(state)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:set_tab, id}, _from, state) do
    Logger.info("set_tab #{inspect(id)}")
    state = %State{state | tab: id}
    state = set_root_and_reset_timer(state)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:reset_screensaver}, _from, state) do
    Logger.info("reset_screensaver")
    # Unlike other functions, this should ensure screen is on even if no change in scene.
    state = set_root_and_reset_timer(state)
    {:reply, :ok, state}
  end
end
