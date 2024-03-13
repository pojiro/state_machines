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

  def callback_mode, do: :state_functions

  def init(code) when is_list(code) do
    do_lock()
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

  def locked(:cast, {:button, button}, %{code: code, length: length, buttons: buttons} = data) do
    new_buttons =
      if length(buttons) < length do
        buttons
      else
        tl(buttons)
      end ++ [button]

    if new_buttons == code do
      do_unlock()
      {:next_state, :open, %{data | buttons: []}, [{:state_timeout, 10_000, :lock}]}
    else
      {:next_state, :locked, %{data | buttons: new_buttons}}
    end
  end

  def locked(event_type, event_content, data) do
    handle_common(event_type, event_content, data)
  end

  def open(:state_timeout, :lock, data) do
    Logger.debug("state_timeout")
    do_lock()
    # return {:keep_state, data} or :keep_state_and_data are the same
    {:next_state, :locked, data}
  end

  def open(:cast, {:button, _}, data) do
    {:next_state, :open, data}
  end

  def open(event_type, event_content, data) do
    handle_common(event_type, event_content, data)
  end

  def handle_common({:call, from}, :code_length, %{code: code} = data) do
    {:keep_state, data, [{:reply, from, length(code)}]}
  end

  def do_lock(), do: IO.inspect("Lock")
  def do_unlock(), do: IO.inspect("Unlock")
end
