defmodule Toast.ActionTest do
  use Toast.LiveCase, async: true

  setup %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")
    render_hook(view, "toast_with_action", %{})
    %{view: view}
  end

  test "action sends the toast's event to the LiveView", %{view: view} do
    view
    |> with_target(".live-toast-group")
    |> render_hook("action", %{"toast_id" => "act", "action" => ~s({"event":"undo"})})

    assert view |> element("#last-action") |> render() =~ ~s({:undo, %{&quot;id&quot; =&gt; 1}})
    wait_for_fade()
    refute has_element?(view, "#toasts-act")
  end

  test "action ignores an event edited in the browser", %{view: view} do
    view
    |> with_target(".live-toast-group")
    |> render_hook("action", %{
      "toast_id" => "act",
      "action" => ~s({"event":"forged_event_name","params":{"x":1}})
    })

    html = view |> element("#last-action") |> render()
    assert html =~ ":undo"
    refute html =~ "forged_event_name"
  end

  test "action for an unknown toast sends nothing", %{view: view} do
    view
    |> with_target(".live-toast-group")
    |> render_hook("action", %{"toast_id" => "nope", "action" => ~s({"event":"undo"})})

    refute has_element?(view, "#last-action")
  end
end
