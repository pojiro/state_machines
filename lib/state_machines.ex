defmodule StateMachines do
  @moduledoc """
  Documentation for `StateMachines`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> StateMachines.hello()
      :world

  """
  def hello do
    :world
  end

  def stop_application() do
    Application.stop(:state_machines)
  end
end
