defmodule StateMachines.HandleEventFunction do
  @behaviour :gen_statem

  def start_link(args) do
    :gen_statem.start_link({:local, __MODULE__}, __MODULE__, args, [])
  end

  def callback_mode, do: :handle_event_function

  def init(_args) do
    {:ok, :init, %{}}
  end

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]}
    }
  end
end
