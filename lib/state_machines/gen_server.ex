defmodule StateMachines.GenServer do
  use GenServer

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def button(button) do
    GenServer.cast(__MODULE__, {:button, button})
  end

  def init(code) when is_list(code) do
    Process.flag(:trap_exit, true)
    {:ok, %{state: :locked, code: code, length: length(code), buttons: []}}
  end

  def terminate(reason, data) do
    Logger.error("#{inspect(reason)}")
    if data.state != :locked, do: do_lock()
    :ok
  end

  def handle_info(:timeout, %{state: :locked} = data) do
    Logger.debug("input timeout, buttons are cleared")
    {:noreply, %{data | buttons: []}}
  end

  def handle_info(:timeout, %{state: :open} = data) do
    {:noreply, %{data | state: :locked}, {:continue, nil}}
  end

  def handle_info(:lock, data) do
    {:noreply, %{data | state: :locked}, {:continue, nil}}
  end

  def handle_cast(
        {:button, button},
        %{state: :locked, code: code, length: length, buttons: buttons} = data
      ) do
    new_buttons =
      if length(buttons) < length do
        buttons
      else
        tl(buttons)
      end ++ [button]

    if new_buttons == code do
      {:noreply, %{data | state: :open, buttons: []}, {:continue, nil}}
    else
      {:noreply, %{data | buttons: new_buttons}, 10_000}
    end
  end

  def handle_cast({:button, _}, %{state: :open} = data) do
    {:noreply, data}
  end

  def handle_continue(nil, %{state: :open} = data) do
    Logger.debug("enter open state")
    do_unlock()
    Process.send_after(self(), :lock, 10_000)
    {:noreply, data, 10_000}
  end

  def handle_continue(nil, %{state: :locked} = data) do
    Logger.debug("enter locked state")
    do_lock()
    {:noreply, data}
  end

  def do_lock(), do: Logger.info("Lock")
  def do_unlock(), do: Logger.info("Unlock")
end
