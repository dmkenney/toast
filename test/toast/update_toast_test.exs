defmodule Toast.UpdateToastTest do
  use Toast.LiveCase, async: true

  test "update_toast replaces the toast's message and type", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")
    render_hook(view, "toast_with_id", %{"id" => "job", "message" => "Working"})

    assert has_element?(view, "#toasts-job .toast-loading", "Working")

    render_hook(view, "update_toast", %{"id" => "job", "message" => "Done"})

    assert has_element?(view, "#toasts-job .toast-success", "Done")
    refute has_element?(view, "#toasts-job .toast-loading")
    refute render(view) =~ "Working"
  end

  test "update_toast with an unknown id is a no-op", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")
    render_hook(view, "toast_with_id", %{"id" => "job", "message" => "Working"})

    render_hook(view, "update_toast", %{"id" => "missing", "message" => "Done"})

    assert has_element?(view, "#toasts-job .toast-loading", "Working")
    refute has_element?(view, "#toasts-missing")
    refute render(view) =~ "Done"
  end

  test "a cleared toast doesn't come back when updated", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")
    render_hook(view, "toast_with_id", %{"id" => "job", "message" => "Working"})
    render_hook(view, "clear_toast", %{"id" => "job"})
    refute has_element?(view, "#toasts-job")

    render_hook(view, "update_toast", %{"id" => "job", "message" => "Done"})

    refute has_element?(view, "#toasts-job")
  end

  test "a toast closed from the client doesn't come back when updated", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")
    render_hook(view, "toast_with_id", %{"id" => "job", "message" => "Working"})

    view |> with_target(".live-toast-group") |> render_hook("clear", %{"id" => "job"})

    wait_for_fade()
    refute has_element?(view, "#toasts-job")

    render_hook(view, "update_toast", %{"id" => "job", "message" => "Done"})

    refute has_element?(view, "#toasts-job")
  end
end
