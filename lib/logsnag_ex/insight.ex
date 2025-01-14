defmodule LogsnagEx.Insight do
  @moduledoc """
  LogSnag Insight API Client.

  ## Usage

      # Track an insight
      LogsnagEx.Insight.track("Active Users", 100, icon: "👥")

      # Increment an insight
      LogsnagEx.Insight.increment("Active Users", 1)
  """

  @type value :: integer() | float() | String.t()

  @doc """
  Publishes a new insight to LogSnag.
  """
  def track(title, value, opts \\ []) do
    client = Application.get_env(:logsnag_ex, :client, LogsnagEx.Client)
    config = Application.get_env(:logsnag_ex, :default, [])

    body =
      %{
        title: title,
        value: value,
        project: config[:project],
        icon: Keyword.get(opts, :icon)
      }
      |> remove_nil_values()

    client.request(:post, "/insight", body, client)
  end

  @doc """
  Increments an existing insight.
  """
  def increment(title, value, opts \\ []) when is_number(value) do
    client = Application.get_env(:logsnag_ex, :client, LogsnagEx.Client)
    config = Application.get_env(:logsnag_ex, :default, [])

    body =
      %{
        title: title,
        value: %{"$inc" => value},
        project: config[:project],
        icon: Keyword.get(opts, :icon)
      }
      |> remove_nil_values()

    client.request(:patch, "/insight", body, client)
  end

  defp remove_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
