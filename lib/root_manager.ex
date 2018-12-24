defmodule RoboticaUi.RootManager do
  @moduledoc false

  use GenServer

  alias Scenic.ViewPort

  defmodule State do
    @type t :: %__MODULE__{
            root: atom() | {atom(), any()} | nil,
            message: atom() | {atom(), any()} | nil
          }
    defstruct [:root, :message]
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: RoboticaUi.RootManager)
  end

  def init(_opts) do
    {:ok, %State{}}
  end

  @spec set_scene(String.t(), atom() | {atom(), any()} | nil) :: nil
  def set_scene(id, scene) do
    GenServer.call(RoboticaUi.RootManager, {:set_scene, id, scene})
  end

  @spec set_root(State.t()) :: nil
  defp set_root(%State{} = state) do
    root_scene =
      cond do
        not is_nil(state.message) -> state.message
        true -> state.root
      end

    ViewPort.set_root(:main_viewport, root_scene)
  end

  def handle_call({:set_scene, id, scene}, _from, state) do
    state = %{state | id => scene}
    set_root(state)
    {:reply, :ok, state}
  end
end
