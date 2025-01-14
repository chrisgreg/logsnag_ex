defmodule LogsnagEx.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {LogsnagEx.Client, Application.get_env(:logsnag_ex, :default, [])}
    ]

    opts = [strategy: :one_for_one, name: LogsnagEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
