defmodule Toast.ProgressTest do
  use Toast.LiveCase, async: true

  setup %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")
    %{view: view}
  end

  test "renders a progress bar with the value", %{view: view} do
    render_hook(view, "toast_with_progress", %{"progress" => 45})

    html = view |> element("#toasts-prog progress.toast-progress") |> render()
    assert html =~ ~s(value="45")
    assert html =~ ~s(max="100")
    assert html =~ ~s(aria-label="Exporting")
  end

  test "labels the bar with the title when there is one", %{view: view} do
    render_hook(view, "toast_with_progress", %{"progress" => 10, "title" => "SLA issues"})

    assert has_element?(view, ~s(#toasts-prog progress[aria-label="SLA issues"]))
  end

  test "indeterminate renders a progress bar with no value", %{view: view} do
    render_hook(view, "toast_with_progress", %{"progress" => "indeterminate"})

    html = view |> element("#toasts-prog progress.toast-progress") |> render()
    refute html =~ "value="
  end

  test "values are clamped to 0..100", %{view: view} do
    render_hook(view, "toast_with_progress", %{"progress" => 150})
    assert has_element?(view, ~s(#toasts-prog progress[value="100"]))

    render_hook(view, "update_progress", %{"progress" => -5})
    assert has_element?(view, ~s(#toasts-prog progress[value="0"]))
  end

  test "update_toast changes the value in place", %{view: view} do
    render_hook(view, "toast_with_progress", %{"progress" => 0})
    render_hook(view, "update_progress", %{"progress" => 62.5})

    assert has_element?(view, ~s(#toasts-prog progress[value="62.5"]))
    assert has_element?(view, ~s(#toasts-prog .toast[data-duration="0"]))
  end

  test "update_toast with progress nil removes the bar", %{view: view} do
    render_hook(view, "toast_with_progress", %{"progress" => 50})
    render_hook(view, "update_progress", %{"progress" => nil})

    assert has_element?(view, "#toasts-prog .toast")
    refute has_element?(view, "#toasts-prog progress")
  end

  test "toasts without progress render no bar", %{view: view} do
    render_hook(view, "toast_with_id", %{"id" => "plain", "message" => "Hi"})

    refute has_element?(view, "#toasts-plain progress")
  end

  test "the progress bar has no inline style", %{view: view} do
    render_hook(view, "toast_with_progress", %{"progress" => 30})

    refute render(view) =~ "style="
  end

  # On LiveView 1.1+ the toast gets a stable id, so update_toast patches it in
  # place instead of replacing it. Older versions keep replacing it.
  test "the toast has a stable id only when LiveView can patch it in place", %{view: view} do
    render_hook(view, "toast_with_progress", %{"progress" => 30})

    if Toast.Components.patch_in_place?() do
      assert has_element?(view, "#toasts-prog #toast-body-prog")
      render_hook(view, "update_progress", %{"progress" => 40})
      assert has_element?(view, ~s(#toast-body-prog progress[value="40"]))
    else
      refute has_element?(view, "#toast-body-prog")
    end
  end
end
