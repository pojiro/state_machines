defmodule StateMachines.CatFsm do
  require Logger

  def start() do
    spawn(fn -> dont_give_crap() end)
  end

  def event(pid, event) do
    ref = make_ref()

    send(pid, {self(), ref, event})

    receive do
      {_ref, msg} -> {:ok, msg}
    after
      5000 ->
        {:error, :timeout}
    end
  end

  def dont_give_crap() do
    receive do
      {pid, ref, _msg} -> send(pid, {ref, :meh})
      _ -> :ok
    end

    Logger.info("Switching to 'dont_give_crap' state")
    dont_give_crap()
  end
end
