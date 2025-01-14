defmodule LogsnagEx.InsightTest do
  use ExUnit.Case
  doctest LogsnagEx.Insight

  import Mox

  setup :verify_on_exit!

  setup do
    Application.put_env(:logsnag_ex, :default,
      token: "test-token",
      project: "test-project",
      disabled: false
    )

    :ok
  end

  test "track/3 sends an insight" do
    expect(LogsnagEx.MockClient, :request, fn method, endpoint, body, _name ->
      assert method == :post
      assert endpoint == "/insight"
      assert body.title == "Active Users"
      assert body.value == 100
      assert body.icon == "👥"
      assert body.project == "test-project"
      {:ok, %{"success" => true}}
    end)

    assert {:ok, %{"success" => true}} = LogsnagEx.Insight.track("Active Users", 100, icon: "👥")
  end

  test "increment/3 increments an insight" do
    expect(LogsnagEx.MockClient, :request, fn method, endpoint, body, _name ->
      assert method == :patch
      assert endpoint == "/insight"
      assert body.title == "Active Users"
      assert body.value == %{"$inc" => 1}
      assert body.project == "test-project"
      {:ok, %{"success" => true}}
    end)

    assert {:ok, %{"success" => true}} = LogsnagEx.Insight.increment("Active Users", 1)
  end
end
