defmodule StateMachines.DogFsm do
  require Logger

  def start() do
    spawn(fn -> bark() end)
  end

  def squirrel(pid), do: send(pid, :squirrel)
  def pet(pid), do: send(pid, :pet)

  def bark() do
    Logger.info("Dog says: BARK! BARK!")

    receive do
      :pet ->
        wag_tail()

      _ ->
        Logger.info("Dog is confused")
        bark()
    after
      2000 -> bark()
    end
  end

  def wag_tail() do
    Logger.info("Dog wags its tail")

    receive do
      :pet ->
        sit()

      _ ->
        Logger.info("Dog is confused")
        wag_tail()
    after
      30000 -> bark()
    end
  end

  def sit() do
    Logger.info("Dog is sitting. Gooooood boy!")

    receive do
      :squirrel ->
        bark()

      _ ->
        Logger.info("Dog is confused")
        sit()
    end
  end
end
