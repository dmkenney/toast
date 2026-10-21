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
end
