defmodule StateMachines.StateFunctions do
  @behaviour :gen_statem

  require Logger

  def start_link(args) do
    :gen_statem.start_link({:local, __MODULE__}, __MODULE__, args, [])
  end

  def button(button) do
    :gen_statem.cast(__MODULE__, {:button, button})
  end

  def code_length() do
    :gen_statem.call(__MODULE__, :code_length)
  end

  def callback_mode, do: [:state_functions, :state_enter]

  def init(code) when is_list(code) do
    Process.flag(:trap_exit, true)
    data = %{code: code, length: length(code), buttons: []}
    {:ok, :locked, data}
  end

  def terminate(reason, state, _data) do
    Logger.error("#{inspect(reason)}")
    if state != :locked, do: do_lock()
    :ok
  end

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]}
    }
  end

  def locked(:enter, _old_state, data) do
    Logger.debug("enter locked state")
    do_lock()
    {:keep_state, data}
  end

  def locked(:cast, {:button, button}, %{code: code, length: length, buttons: buttons} = data) do
    new_buttons =
      if length(buttons) < length do
        buttons
      else
        tl(buttons)
      end ++ [button]

    if new_buttons == code do
      {:next_state, :open, %{data | buttons: []}}
    else
      {:keep_state, %{data | buttons: new_buttons}, 30_000}
    end
  end

  def locked(:timeout, _event_content, data) do
    Logger.debug("input timeout, buttons are cleared")
    {:keep_state, %{data | buttons: []}}
  end

  def locked(event_type, event_content, data) do
    handle_common(event_type, event_content, data)
  end

  def open(:enter, _old_state, _data) do
    Logger.debug("enter open state")
    do_unlock()
    {:keep_state_and_data, [{{:timeout, :open}, 10_000, :lock}]}
  end

  def open({:timeout, :open} = event_type, :lock, data) do
    Logger.debug("#{inspect(event_type)}")
    # return {:keep_state, data} or :keep_state_and_data are the same
    {:next_state, :locked, data}
  end

  def open(:cast, {:button, _}, data) do
    {:keep_state, data, [:postpone]}
  end

  def open(event_type, event_content, data) do
    handle_common(event_type, event_content, data)
  end

  def handle_common({:call, from}, :code_length, %{code: code} = data) do
    {:keep_state, data, [{:reply, from, length(code)}]}
  end

  def do_lock(), do: Logger.info("Lock")
  def do_unlock(), do: Logger.info("Unlock")
end
