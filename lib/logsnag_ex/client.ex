defmodule LogsnagEx.Client do
  @moduledoc """
  LogSnag client process that maintains the configuration and handles API requests.
  """
  use GenServer
  @behaviour LogsnagEx.ClientBehaviour

  defstruct [:token, :project, :disabled, :req_client]

  @base_url "https://api.logsnag.com/v1"

  # Client API

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def get_config(name \\ __MODULE__) do
    GenServer.call(name, :get_config)
  end

  # Server callbacks

  @impl GenServer
  def init(opts) do
    config = %{
      token: Keyword.get(opts, :token, "test-token"),
      project: Keyword.get(opts, :project, "test-project"),
      disabled: Keyword.get(opts, :disabled, false),
      req_client: Req.new(base_url: @base_url)
    }

    {:ok, config}
  end

  @impl true
  def handle_call(:get_config, _from, config) do
    {:reply, config, config}
  end

  # HTTP Client helpers

  @impl LogsnagEx.ClientBehaviour
  def request(method, endpoint, body, _name) do
    config = Application.get_env(:logsnag_ex, :default, [])

    if config[:disabled] do
      {:ok, :disabled}
    else
      body = Map.put(body, :project, config[:project])

      Req.new(base_url: "https://api.logsnag.com/v1")
      |> Req.request(
        method: method,
        url: endpoint,
        json: body,
        headers: [
          {"Authorization", "Bearer #{config[:token]}"}
        ]
      )
      |> handle_response()
    end
  end

  defp handle_response({:ok, %{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp handle_response({:ok, %{body: body}}) do
    {:error, Map.get(body, "message", "Failed to publish")}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end
end
