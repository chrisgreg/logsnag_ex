# LogsnagEx

[![Hex.pm](https://img.shields.io/hexpm/v/logsnag_ex.svg)](https://hex.pm/packages/logsnag_ex)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/logsnag_ex)

An Elixir client for [LogSnag](https://logsnag.com) - The event tracking platform for monitoring your products, services, and user behavior.

## Installation

Add `logsnag` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logsnag_ex, "~> 0.1.0"}
  ]
end
```

## Configuration

Configure LogSnag in your `config/config.exs` (or environment-specific config file):

```elixir
config :logsnag_ex,
  default: [
    token: "your-token",
    project: "your-project",
    disabled: Mix.env() != :prod # optional, defaults to false
  ]
```

For multiple environments, you might want to use environment variables:

```elixir
config :logsnag_ex,
  default: [
    token: System.get_env("LOGSNAG_TOKEN"),
    project: System.get_env("LOGSNAG_PROJECT")
  ]
```

### Multiple Clients

You can configure multiple LogSnag clients for different purposes:

```elixir
config :logsnag_ex,
  default: [
    token: "default-token",
    project: "default-project"
  ],
  analytics: [
    token: "analytics-token",
    project: "analytics-project",
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

## Usage

### Tracking Events

```elixir
# Simple event
LogsnagEx.track("user-signup", "New User Registered")

# Event with description and icon
LogsnagEx.track("payments", "Payment Received",
  description: "User completed payment for premium plan",
  icon: "💰"
)

# Event with tags and notification
LogsnagEx.track("orders", "Order Fulfilled",
  tags: %{
    order_id: "12345",
    amount: "$99.99"
  },
  notify: true
)

# Event with custom client
LogsnagEx.track("analytics", "Page View",
  client: MyApp.AnalyticsLogSnag
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
config :logsnag,
  default: [
    token: "test-token",
    project: "test-project",
    disabled: true
  ]
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
