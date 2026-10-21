defmodule Toast.ThemeTest do
  use Toast.LiveCase, async: true

  test "theme=system is set on the toast container and flash group", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/system-theme")

    assert has_element?(view, ~s(#toast-group[data-theme="system"]))

    view |> render_hook("flash", %{"message" => "Flash in system theme"})

    assert has_element?(
             view,
             ~s(.flash-messages[data-theme="system"][data-rich-colors="true"]),
             "Flash in system theme"
           )
  end
end
