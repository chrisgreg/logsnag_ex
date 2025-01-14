# LogsnagEx

[![Hex.pm](https://img.shields.io/hexpm/v/logsnag_ex.svg)](https://hex.pm/packages/logsnag_ex)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/logsnag_ex)

An Elixir client for [LogSnag](https://logsnag.com) - The event tracking platform for monitoring your products, services, and user behavior.

## Installation

Add `logsnag_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logsnag_ex, "~> 1.0.0"}
  ]
end
```

## Configuration

Configure LogSnag in your `config/config.exs` (or environment-specific config file):

```elixir
config :logsnag_ex,
  default: [
    token: System.get_env("LOGSNAG_TOKEN"),
    project: System.get_env("LOGSNAG_PROJECT"),
    disabled: Mix.env() != :prod # optional, defaults to false
  ]
```

### Multiple Clients

You can configure multiple LogSnag clients for different purposes:

```elixir
config :logsnag_ex,
  default: [
    token: System.get_env("LOGSNAG_TOKEN"),
    project: System.get_env("LOGSNAG_PROJECT")
  ],
  analytics: [
    token: System.get_env("LOGSNAG_TOKEN"),
    project: System.get_env("LOGSNAG_PROJECT_2"),
    name: MyApp.AnalyticsLogSnag
  ]
```

Then in your application supervision tree:

```elixir
children = [
  {LogsnagEx.Client, Application.get_env(:logsnag_ex, :default, [])},
  {LogsnagEx.Client, Application.get_env(:logsnag_ex, :analytics, [])}
]
```

## Setup

The library is an OTP application, so it will automatically start its supervision tree. You don't need to add anything to your supervision tree unless you're using multiple clients.

### Single Client (Default)

Just add the configuration to your `config/config.exs`:

```elixir
config :logsnag_ex,
  default: [
    token: System.get_env("LOGSNAG_TOKEN"),
    project: System.get_env("LOGSNAG_PROJECT")
  ]
```

### Multiple Clients

For multiple clients, configure them in your config:

```elixir
config :logsnag_ex,
  default: [
    token: System.get_env("LOGSNAG_TOKEN"),
    project: System.get_env("LOGSNAG_PROJECT")
  ],
  analytics: [
    token: System.get_env("LOGSNAG_TOKEN"),
    project: System.get_env("LOGSNAG_PROJECT_2"),
    client: MyApp.AnalyticsLogSnag
  ]
```

Then add the additional clients to your supervision tree:

```elixir
# lib/your_app/application.ex
def start(_type, _args) do
  children = [
    # ... your other children ...
    {LogsnagEx.Client, Application.get_env(:logsnag_ex, :analytics, [])}
  ]

  opts = [strategy: :one_for_one, name: YourApp.Supervisor]
  Supervisor.start_link(children, opts)
end
```

## Usage

### Tracking Events

```elixir
# Simple event
LogsnagEx.track("user-signup", "New User Registered")

# Event with all options
LogsnagEx.track("payments", "Payment Received",
  description: "User completed payment for premium plan",
  icon: "💰",
  tags: %{
    order_id: "12345",
    amount: "$99.99"
  },
  notify: true,
  user_id: "user-123",  # Optional user association
  parser: "markdown",   # Optional: "markdown" or "text"
  date: DateTime.utc_now()  # Optional timestamp
)
```

### Using Insights

Insights help you track metrics and KPIs:

```elixir
# Track a metric
LogsnagEx.Insight.track("Active Users", 100, icon: "👥")

# Increment a metric
LogsnagEx.Insight.increment("Total Sales", 99.99)

# Using custom client
LogsnagEx.Insight.track("Daily Revenue", 10_000,
  client: MyApp.AnalyticsLogSnag
)
```

### User Identification

Track user properties:

```elixir
LogsnagEx.identify("user-123",
  %{
    email: "user@example.com",
    name: "John Doe",
    plan: "premium"
  }
)
```

### Group Tracking

Track organization or group properties:

```elixir
LogsnagEx.group("user-123", "org-456",
  %{
    name: "Acme Corp",
    plan: "enterprise",
    employees: 50
  }
)
```

## Options

### Event Tracking Options

- `:description` - Additional details about the event
- `:icon` - Single emoji to represent the event
- `:tags` - Map of key-value pairs for additional data
- `:notify` - Boolean to enable push notifications
- `:parser` - String "markdown" or "text" for description parsing
- `:date` - DateTime for historical events
- `:client` - Atom name of custom client to use

### Insight Options

- `:icon` - Single emoji to represent the insight
- `:client` - Atom name of custom client to use

## Development Environment

For development or testing, you can disable tracking:

```elixir
config :logsnag_ex,
  default: [
    token: "test-token",
    project: "test-project",
    disabled: true
  ]
```

## Testing

The package uses Mox for testing. In your `test_helper.exs`:

```elixir
Mox.defmock(LogsnagEx.MockClient, for: LogsnagEx.Client.Behaviour)
Application.put_env(:logsnag_ex, :client_module, LogsnagEx.MockClient)
```

Example test:

```elixir
test "track/3 sends a log event" do
  expect(LogsnagEx.MockClient, :request, fn :post, "/log", body, _name ->
    assert body["channel"] == "test-channel"
    assert body["event"] == "test-event"
    {:ok, body}
  end)

  assert {:ok, response} = LogsnagEx.track("test-channel", "test-event")
end
```

## Error Handling

All functions return `{:ok, result}` or `{:error, error}`:

```elixir
case LogsnagEx.track("channel", "event") do
  {:ok, response} ->
    # Handle success
  {:error, %LogsnagEx.Error{message: message, data: data}} ->
    # Handle error
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT License. See LICENSE for details.
