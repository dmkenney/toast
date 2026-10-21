defmodule Toast.ConnectionToastsTest do
  use Toast.LiveCase, async: true

  test "connection toasts are not rendered by default", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    refute has_element?(view, "#toast-group-client-error")
    refute has_element?(view, "#toast-group-server-error")
  end

  test "connection toasts render hidden with connection bindings", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/connection")

    for kind <- ["client", "server"] do
      selector = "#toast-group-#{kind}-error"

      assert has_element?(view, "#{selector}.toast.toast-error[hidden]")
      assert has_element?(view, "#{selector}[phx-disconnected*='phx-#{kind}-error']")
      assert has_element?(view, "#{selector}[phx-connected]")
    end
  end

  test "connection toast text can be overridden", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/connection")

    assert has_element?(view, "#toast-group-client-error .toast-title", "Offline")

    assert has_element?(
             view,
             "#toast-group-client-error .toast-message",
             "Attempting to reconnect"
           )

    assert has_element?(view, "#toast-group-server-error .toast-title", "Something went wrong!")
  end
end
