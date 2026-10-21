defmodule Toast.NavigationTest do
  use Toast.LiveCase, async: true

  test "put_toast renders a toast on the same LiveView", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    view |> render_hook("toast", %{"message" => "Saved"})

    assert render(view) =~ "Saved"
  end

  test "put_flash survives push_navigate", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    {:ok, target, _html} =
      view
      |> render_hook("flash_and_navigate", %{"message" => "Flash carried over"})
      |> follow_redirect(conn, "/target")

    assert render(target) =~ "Flash carried over"
  end

  # https://github.com/dmkenney/toast/issues/10
  test "put_toast survives push_navigate", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    {:ok, target, _html} =
      view
      |> render_hook("toast_and_navigate", %{"message" => "Toast carried over"})
      |> follow_redirect(conn, "/target")

    assert render(target) =~ "Toast carried over"
  end

  test "put_toast keeps its options after push_navigate", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    {:ok, target, _html} =
      view
      |> render_hook("toast_and_navigate", %{"message" => "Toast carried over"})
      |> follow_redirect(conn, "/target")

    assert target |> element(".toast-success") |> render() =~ ~s(data-duration="10000")
  end

  test "several put_toast calls all survive push_navigate", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    {:ok, target, _html} =
      view
      |> render_hook("two_toasts_and_navigate", %{})
      |> follow_redirect(conn, "/target")

    html = render(target)
    assert html =~ "First toast"
    assert html =~ "Second toast"
    # Newest on top, same as two send_toast calls
    assert :binary.match(html, "Second toast") < :binary.match(html, "First toast")
  end

  test "put_toast survives redirect", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    {:ok, conn} =
      view
      |> render_hook("toast_and_redirect", %{"message" => "Redirect toast"})
      |> follow_redirect(conn, "/target")

    # The toast is added once the LiveView connects, not in the dead render.
    refute html_response(conn, 200) =~ "Redirect toast"
    {:ok, target, _html} = live(conn)
    assert target |> render() |> count("Redirect toast") == 1
  end

  test "put_toast without navigation shows the toast once", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    render_hook(view, "toast", %{"message" => "Only once"})
    render_hook(view, "rerender", %{})

    assert view |> render() |> count("Only once") == 1
    refute render(view) =~ "__toast__"
  end

  test "a dismissed put_toast does not come back on re-render", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    render_hook(view, "toast", %{"message" => "Dismiss me"})

    [id] =
      view |> render() |> Floki.parse_fragment!() |> Floki.attribute(".toast", "data-toast-id")

    view |> with_target(".live-toast-group") |> render_hook("clear", %{"id" => id})

    wait_for_fade()
    refute render(view) =~ "Dismiss me"

    render_hook(view, "rerender", %{})
    refute render(view) =~ "Dismiss me"
  end

  test "an earlier put_toast is not carried by a later navigation", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    render_hook(view, "toast", %{"message" => "Old toast"})

    {:ok, target, _html} =
      view
      |> render_hook("toast_and_navigate", %{"message" => "New toast"})
      |> follow_redirect(conn, "/target")

    html = render(target)
    assert html =~ "New toast"
    refute html =~ "Old toast"
  end

  test "put_toast from a LiveComponent shows the toast", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    view |> element("#component-toast") |> render_click()

    assert view |> render() |> count("From component") == 1
  end

  test "put_toast from a LiveComponent is not carried by a later navigation", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    view |> element("#component-toast") |> render_click()

    {:ok, target, _html} =
      view
      |> element("#component-toast-and-navigate")
      |> render_click()
      |> follow_redirect(conn, "/target")

    refute render(target) =~ "From component"
  end

  test "put_toast in mount shows once", %{conn: conn} do
    dead_html = conn |> get("/mount-toast") |> html_response(200)
    refute dead_html =~ "Toast from mount"

    {:ok, view, _html} = live(conn, "/mount-toast")
    assert view |> render() |> count("Toast from mount") == 1
  end

  test "put_toast with a reused id shows the toast again", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    render_hook(view, "toast_with_id", %{"message" => "First save"})
    assert render(view) =~ "First save"

    view |> with_target(".live-toast-group") |> render_hook("clear", %{"id" => "save-toast"})

    wait_for_fade()
    refute render(view) =~ "First save"

    render_hook(view, "toast_with_id", %{"message" => "Second save"})
    assert view |> render() |> count("Second save") == 1
  end

  test "put_toast with a reused id replaces a toast still on screen", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    render_hook(view, "toast_with_id", %{"message" => "First save"})
    render_hook(view, "toast_with_id", %{"message" => "Second save"})

    html = render(view)
    refute html =~ "First save"
    assert count(html, "Second save") == 1
  end

  defp count(html, text), do: length(String.split(html, text)) - 1
end
