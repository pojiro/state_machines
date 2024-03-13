defmodule StateMachines.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {StateMachines.StateFunctions, [1, 2, 3, 4]},
      {StateMachines.HandleEventFunction, [1, 2, 3, 4]},
      {StateMachines.GenServer, [1, 2, 3, 4]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StateMachines.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
