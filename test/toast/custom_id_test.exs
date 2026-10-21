defmodule Toast.CustomIdTest do
  use Toast.LiveCase, async: true

  test "the id attr sets the DOM id of the toast group", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/custom-id")

    assert has_element?(view, "#notifications.live-toast-stream[phx-hook=Toast]")
    assert has_element?(view, "#notifications-client-error")
    assert has_element?(view, "#notifications-server-error")
    refute has_element?(view, "#toast-group")
  end

  test "send_toast, update_toast and clear_toast work with a custom id", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/custom-id")

    render_hook(view, "send", %{"id" => "job", "message" => "Working"})
    assert has_element?(view, "#notifications #toasts-job .toast-loading", "Working")

    render_hook(view, "update", %{"id" => "job", "message" => "Done"})
    assert has_element?(view, "#notifications #toasts-job .toast-success", "Done")

    render_hook(view, "clear", %{"id" => "job"})
    refute has_element?(view, "#toasts-job")
  end

  test "clear_all_toasts works with a custom id", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/custom-id")

    render_hook(view, "send", %{"id" => "one", "message" => "One"})
    render_hook(view, "send", %{"id" => "two", "message" => "Two"})
    assert has_element?(view, "#toasts-two")

    render_hook(view, "clear_all", %{})
    refute has_element?(view, "#toasts-one")
    refute has_element?(view, "#toasts-two")
  end
end
