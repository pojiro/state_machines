defmodule StateMachinesTest do
  use ExUnit.Case
  doctest StateMachines

  test "greets the world" do
    assert StateMachines.hello() == :world
  end
end
