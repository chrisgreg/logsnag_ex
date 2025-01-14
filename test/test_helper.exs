ExUnit.start()

Mox.defmock(LogsnagEx.MockClient, for: LogsnagEx.ClientBehaviour)
Application.put_env(:logsnag_ex, :client, LogsnagEx.MockClient)
