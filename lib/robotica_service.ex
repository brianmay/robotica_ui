defmodule RoboticaUi.RoboticaService do
  @moduledoc false

  use GenServer
  require Logger

  defmodule State do
    @type t :: %__MODULE__{
            scenes: list(GenServer.server())
          }
    defstruct scenes: []
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %State{}}
  end

  def process(event) do
    GenServer.cast(__MODULE__, event)
  end

  @spec register(GenServer.server()) :: nil
  def register(pid) do
    GenServer.call(__MODULE__, {:register, pid})
  end

  def handle_cast({:execute = topic, id}, state) do
    action = EventBus.fetch_event_data({topic, id})

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

    EventBus.mark_as_completed({__MODULE__, topic, id})
    {:noreply, state}
  end

  def handle_cast({:schedule = topic, id}, state) do
    steps = EventBus.fetch_event_data({topic, id})

    Enum.each(state.scenes, fn pid ->
      Scenic.Scene.send_event(pid, {:schedule, steps})
    end)

    EventBus.mark_as_completed({__MODULE__, topic, id})
    {:noreply, state}
  end

  def handle_call({:register, pid}, _from, state) do
    Process.monitor(pid)
    state = %State{state | scenes: [pid | state.scenes]}
    Logger.info("register #{inspect(pid)} #{inspect(state.scenes)}")
    {:reply, nil, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    state = %State{state | scenes: List.delete(state.scenes, pid)}
    Logger.info("unregister #{inspect(pid)} #{inspect(state.scenes)}")
    {:noreply, state}
  end
end
