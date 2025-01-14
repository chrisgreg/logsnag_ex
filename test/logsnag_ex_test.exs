defmodule LogsnagExTest do
  use ExUnit.Case
  doctest LogsnagEx

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

  test "track/3 sends a log event" do
    expect(LogsnagEx.MockClient, :request, fn :post, "/log", body, _name ->
      assert body["channel"] == "test-channel"
      assert body["event"] == "test-event"
      assert body["project"] == "test-project"
      {:ok, body}
    end)

    assert {:ok,
            %{
              "channel" => "test-channel",
              "event" => "test-event",
              "project" => "test-project"
            }} = LogsnagEx.track("test-channel", "test-event")
  end

  test "identify/3 sends user identification" do
    expect(LogsnagEx.MockClient, :request, fn :post, "/identify", body, _name ->
      assert body["user_id"] == "user-123"
      assert body["properties"] == %{name: "John Doe"}
      assert body["project"] == "test-project"
      {:ok, body}
    end)

    assert {:ok,
            %{
              "user_id" => "user-123",
              "properties" => %{name: "John Doe"},
              "project" => "test-project"
            }} = LogsnagEx.identify("user-123", %{name: "John Doe"})
  end

  test "group/4 sends group identification" do
    expect(LogsnagEx.MockClient, :request, fn :post, "/group", body, _name ->
      assert body["user_id"] == "user-123"
      assert body["group_id"] == "group-456"
      assert body["properties"] == %{name: "Test Group"}
      assert body["project"] == "test-project"
      {:ok, body}
    end)

    assert {:ok,
            %{
              "user_id" => "user-123",
              "group_id" => "group-456",
              "properties" => %{name: "Test Group"},
              "project" => "test-project"
            }} = LogsnagEx.group("user-123", "group-456", %{name: "Test Group"})
  end
end
