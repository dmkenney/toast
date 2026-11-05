defmodule Toast.ClearFlashTest do
  use Toast.LiveCase, async: true

  setup %{conn: conn} do
    {:ok, view, _html} = live(conn, "/flash-durations")
    %{view: view}
  end

  test "clear_flash with a key removes that flash", %{view: view} do
    render_hook(view, "flash", %{"type" => "error", "message" => "Failed"})
    render_hook(view, "flash", %{"type" => "info", "message" => "Saved"})
    assert has_element?(view, "#flash-error", "Failed")

    render_hook(view, "clear_flash", %{"type" => "error"})

    refute has_element?(view, "#flash-error")
    assert has_element?(view, "#flash-info", "Saved")
  end

  test "clear_flash with no key removes every flash", %{view: view} do
    render_hook(view, "flash", %{"type" => "error", "message" => "Failed"})
    render_hook(view, "flash", %{"type" => "info", "message" => "Saved"})

    render_hook(view, "clear_flash", %{})

    refute has_element?(view, "#flash-error")
    refute has_element?(view, "#flash-info")
  end

  test "a new message under the same key replaces the old one", %{view: view} do
    render_hook(view, "flash", %{"type" => "info", "message" => "First"})
    render_hook(view, "flash", %{"type" => "info", "message" => "Second"})

    assert has_element?(view, "#flash-info", "Second")
    refute render(view) =~ "First"
  end

  test "send_toast doesn't remove a shown flash", %{view: view} do
    render_hook(view, "flash", %{"type" => "error", "message" => "Failed"})

    render_hook(view, "toast", %{"message" => "Hello"})

    assert has_element?(view, "#flash-error", "Failed")
    assert render(view) =~ "Hello"
  end

  test "clear_flash leaves toasts from put_toast alone", %{view: view} do
    render_hook(view, "put_toast", %{"message" => "From put_toast"})
    render_hook(view, "flash", %{"type" => "error", "message" => "Failed"})

    render_hook(view, "clear_flash", %{})

    refute has_element?(view, "#flash-error")
    assert has_element?(view, ".live-toast-stream .toast-success", "From put_toast")
  end
end
