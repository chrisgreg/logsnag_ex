defmodule LogsnagEx do
  @moduledoc """
  LogSnag API Client for Elixir.

  ## Configuration

  Add to your config/config.exs:

      config :logsnag_ex,
        default: [
          token: "your-token",
          project: "your-project",
          disabled: false # optional
        ]

  ## Usage

      # Track an event
      LogsnagEx.track("channel", "event", description: "Something happened")

      # Track with a different client
      LogsnagEx.track("channel", "event", client: MyApp.LogSnag)
  """

  @doc """
  Publishes a new log to LogSnag.
  """
  def track(channel, event, opts \\ []) do
    client = Application.get_env(:logsnag_ex, :client, LogsnagEx.Client)
    config = Application.get_env(:logsnag_ex, :default, [])

    body =
      %{
        "channel" => channel,
        "event" => event,
        "project" => config[:project],
        "user_id" => Keyword.get(opts, :user_id),
        "description" => Keyword.get(opts, :description),
        "icon" => Keyword.get(opts, :icon),
        "tags" => Keyword.get(opts, :tags),
        "notify" => Keyword.get(opts, :notify),
        "parser" => Keyword.get(opts, :parser),
        "timestamp" => maybe_convert_timestamp(Keyword.get(opts, :date))
      }
      |> remove_nil_values()

    client.request(:post, "/log", body, client)
  end

  @doc """
  Identifies a user in LogSnag.
  """
  def identify(user_id, properties) do
    client = Application.get_env(:logsnag_ex, :client, LogsnagEx.Client)
    config = Application.get_env(:logsnag_ex, :default, [])

    body = %{
      "user_id" => user_id,
      "properties" => properties,
      "project" => config[:project]
    }

    client.request(:post, "/identify", body, client)
  end

  @doc """
  Identifies a group in LogSnag.
  """
  def group(user_id, group_id, properties) do
    client = Application.get_env(:logsnag_ex, :client, LogsnagEx.Client)
    config = Application.get_env(:logsnag_ex, :default, [])

    body = %{
      "user_id" => user_id,
      "group_id" => group_id,
      "properties" => properties,
      "project" => config[:project]
    }

    client.request(:post, "/group", body, client)
  end

  defp maybe_convert_timestamp(nil), do: nil
  defp maybe_convert_timestamp(%DateTime{} = date), do: DateTime.to_unix(date)

  defp remove_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
