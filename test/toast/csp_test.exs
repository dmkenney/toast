defmodule Toast.CSPTest do
  # A strict Content-Security-Policy (style-src without 'unsafe-inline')
  # blocks inline style attributes, so Toast markup must not render any.
  use Toast.LiveCase, async: true

  test "toast group renders without inline style attributes", %{conn: conn} do
    conn = get(conn, "/source")
    html = html_response(conn, 200)

    assert html =~ "live-toast-group"
    refute html =~ "style="

    {:ok, view, _html} = live(conn)
    refute render(view) =~ "style="
  end

  test "toasts render without inline style attributes", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    view |> render_hook("toast", %{"message" => "Saved"})
    html = render(view)

    assert html =~ "Saved"
    refute html =~ "style="
  end

  test "flash group renders without inline style attributes", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    {:ok, target, _html} =
      view
      |> render_hook("flash_and_navigate", %{"message" => "Flash carried over"})
      |> follow_redirect(conn, "/target")

    html = render(target)

    assert html =~ "flash-messages"
    assert html =~ "Flash carried over"
    refute html =~ "style="
  end
end
