defmodule Toast.OnDismissTest do
  use Toast.LiveCase, async: true

  setup %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")
    render_hook(view, "toast_with_dismiss", %{})
    %{view: view}
  end

  defp toast_event(view, event, params) do
    view |> with_target(".live-toast-group") |> render_hook(event, params)
  end

  defp messages(view), do: view |> element("#messages") |> render()

  test "closing the toast sends on_dismiss with reason closed", %{view: view} do
    toast_event(view, "clear", %{"id" => "exp"})

    assert messages(view) =~
             ~s({:export_closed, %{&quot;id&quot; =&gt; 7, &quot;reason&quot; =&gt; &quot;closed&quot;}})
  end

  test "a timed out toast sends reason timeout", %{view: view} do
    toast_event(view, "clear", %{"id" => "exp", "reason" => "timeout"})

    assert messages(view) =~ ~s(&quot;reason&quot; =&gt; &quot;timeout&quot;)
  end

  test "an unknown reason from the client counts as closed", %{view: view} do
    toast_event(view, "clear", %{"id" => "exp", "reason" => "forged"})

    html = messages(view)
    assert html =~ ~s(&quot;reason&quot; =&gt; &quot;closed&quot;)
    refute html =~ "forged"
  end

  test "an action click sends the action, then on_dismiss with reason action", %{view: view} do
    toast_event(view, "action", %{"toast_id" => "exp"})

    assert messages(view) =~
             ~s({:download, %{}} {:export_closed, %{&quot;id&quot; =&gt; 7, &quot;reason&quot; =&gt; &quot;action&quot;}})
  end

  test "on_dismiss is sent once when the toast is closed twice", %{view: view} do
    toast_event(view, "clear", %{"id" => "exp"})
    toast_event(view, "clear", %{"id" => "exp"})

    assert length(:binary.matches(messages(view), ":export_closed")) == 1
  end

  test "clear_toast and update_toast don't send on_dismiss", %{view: view} do
    render_hook(view, "update_toast", %{"id" => "exp", "message" => "Done"})
    render_hook(view, "clear_toast", %{"id" => "exp"})
    toast_event(view, "clear", %{"id" => "exp"})

    refute has_element?(view, "#messages")
  end

  test "a toast without on_dismiss sends nothing when closed", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")
    render_hook(view, "toast_with_id", %{"id" => "plain", "message" => "Hi"})

    toast_event(view, "clear", %{"id" => "plain"})

    refute has_element?(view, "#messages")
  end

  test "a string event name is turned into an atom on the server", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")
    render_hook(view, "toast_with_dismiss", %{"event" => "string_event"})

    toast_event(view, "clear", %{"id" => "exp"})

    assert messages(view) =~ "{:string_event,"
  end

  test "on_dismiss from put_toast survives push_navigate", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    {:ok, target, _html} =
      view
      |> render_hook("put_toast_with_dismiss_and_navigate", %{})
      |> follow_redirect(conn, "/target")

    toast_event(target, "clear", %{"id" => "exp"})

    assert target |> element("#messages") |> render() =~ "{:export_closed,"
  end
end
