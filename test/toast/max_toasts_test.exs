defmodule Toast.MaxToastsTest do
  use Toast.LiveCase, async: true

  # LimitLive renders the group with max_toasts={2} and animation_duration={10}

  test "toasts over the limit are removed by the server", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/limit")

    for id <- ~w(a b c d), do: render_hook(view, "toast", %{"id" => id})

    # They stay long enough for the client to fade them out
    assert has_element?(view, "#toasts-a")
    assert has_element?(view, "#toasts-b")

    Process.sleep(50)

    refute has_element?(view, "#toasts-a")
    refute has_element?(view, "#toasts-b")
    assert has_element?(view, "#toasts-c")
    assert has_element?(view, "#toasts-d")
  end

  test "a toast removed for the limit isn't updated back in", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/limit")

    for id <- ~w(a b c), do: render_hook(view, "toast", %{"id" => id})
    render_hook(view, "update_toast", %{"id" => "a", "message" => "Back"})
    Process.sleep(50)

    refute has_element?(view, "#toasts-a")
    refute render(view) =~ "Back"
  end

  test "a closed toast frees its slot", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/limit")

    for id <- ~w(a b), do: render_hook(view, "toast", %{"id" => id})
    view |> with_target(".live-toast-group") |> render_hook("clear", %{"id" => "b"})
    render_hook(view, "toast", %{"id" => "c"})
    Process.sleep(50)

    assert has_element?(view, "#toasts-a")
    assert has_element?(view, "#toasts-c")
  end
end
