defmodule LogsnagEx.ClientBehaviour do
  @callback request(
              method :: :get | :post | :put | :patch | :delete,
              endpoint :: String.t(),
              body :: map(),
              name :: atom()
            ) :: {:ok, map()} | {:error, any()}
end
