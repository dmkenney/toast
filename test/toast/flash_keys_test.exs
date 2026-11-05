defmodule Toast.FlashKeysTest do
  use Toast.LiveCase, async: true

  import Phoenix.Component, only: [sigil_H: 2]

  describe "toast_group flash_keys" do
    setup %{conn: conn} do
      {:ok, view, _html} = live(conn, "/flash-keys")
      %{view: view}
    end

    test "shows only the listed keys, given as atoms or strings", %{view: view} do
      render_hook(view, "flash", %{"type" => "info", "message" => "Saved"})
      render_hook(view, "flash", %{"type" => "error", "message" => "Failed"})
      render_hook(view, "flash", %{"type" => "email", "message" => "user@example.com"})

      assert has_element?(view, "#flash-info", "Saved")
      assert has_element?(view, "#flash-error", "Failed")
      refute has_element?(view, "#flash-email")
      refute render(view) =~ "user@example.com"
    end

    test "put_toast toasts still show", %{view: view} do
      render_hook(view, "put_toast", %{"message" => "From put_toast"})

      assert has_element?(view, ".live-toast-stream .toast-success", "From put_toast")
    end
  end

  test "toast_group without flash_keys shows every key", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/flash-durations")
    render_hook(view, "flash", %{"type" => "email", "message" => "user@example.com"})

    assert has_element?(view, "#flash-email", "user@example.com")
  end

  describe "Toast.flash_group flash_keys" do
    defp render_static(assigns) do
      ~H"<Toast.flash_group flash={@flash} flash_keys={@keys} />"
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()
    end

    test "hides unlisted keys and keeps put_toast toasts" do
      html =
        render_static(%{
          flash: %{
            "info" => "Saved",
            "email" => "user@example.com",
            "__toast__:1" => %{id: "toast-1", type: :success, message: "From put_toast"}
          },
          keys: ~w(info error)
        })

      assert html =~ "Saved"
      assert html =~ "From put_toast"
      refute html =~ "user@example.com"
    end

    test "nil shows every key" do
      html = render_static(%{flash: %{"email" => "user@example.com"}, keys: nil})

      assert html =~ "user@example.com"
    end
  end
end
