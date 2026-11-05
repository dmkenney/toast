defmodule Toast.FlashDurationsTest do
  use Toast.LiveCase, async: true

  import Phoenix.Component, only: [sigil_H: 2]

  alias Toast.Components

  describe "toast_group flash_durations" do
    setup %{conn: conn} do
      {:ok, view, _html} = live(conn, "/flash-durations")
      %{view: view}
    end

    test "sets data-duration on flash types with a duration", %{view: view} do
      render_hook(view, "flash", %{"type" => "info", "message" => "Saved"})
      render_hook(view, "flash", %{"type" => "warning", "message" => "Careful"})

      assert has_element?(view, ~s(#flash-info[data-duration="6000"]), "Saved")
      assert has_element?(view, ~s(#flash-warning[data-duration="3000"]), "Careful")
    end

    test "leaves other flash types without a duration", %{view: view} do
      render_hook(view, "flash", %{"type" => "error", "message" => "Failed"})

      assert has_element?(view, "#flash-error", "Failed")
      refute has_element?(view, "#flash-error[data-duration]")
    end

    test "a flash closed from the client doesn't come back", %{view: view} do
      render_hook(view, "flash", %{"type" => "info", "message" => "Saved"})

      view
      |> with_target(".live-toast-group")
      |> render_hook("clear-flash", %{"key" => "info", "type" => "info"})

      render_hook(view, "lv:clear-flash", %{"key" => "info"})
      refute has_element?(view, "#flash-info")
    end
  end

  test "toast_group without flash_durations renders no data-duration", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/source")

    {:ok, target, _html} =
      view
      |> render_hook("flash_and_navigate", %{"message" => "Flash carried over"})
      |> follow_redirect(conn, "/target")

    assert has_element?(target, "#flash-info", "Flash carried over")
    refute has_element?(target, "#flash-info[data-duration]")
  end

  describe "Components.flash_group durations" do
    test "matches atom and string flash types and put_toast toasts" do
      assigns = %{
        flash: %{
          :info => "Atom key",
          "success" => "String key",
          "__toast__:1" => %{id: "toast-1", type: :info, message: "From put_toast"}
        },
        durations: %{"info" => 5000, success: 4000}
      }

      html =
        ~H"<Components.flash_group flash={@flash} durations={@durations} />"
        |> Phoenix.HTML.Safe.to_iodata()
        |> IO.iodata_to_binary()

      assert html =~ ~r/id="flash-info"[^>]*data-duration="5000"/s
      assert html =~ ~r/id="flash-success"[^>]*data-duration="4000"/s
      assert html =~ ~r/id="flash-__toast__:1"[^>]*data-duration="5000"/s
    end

    test "ignores zero, negative and non-integer durations" do
      assigns = %{
        flash: %{"info" => "A", "error" => "B", "warning" => "C"},
        durations: %{info: 0, error: -1, warning: "6000"}
      }

      html =
        ~H"<Components.flash_group flash={@flash} durations={@durations} />"
        |> Phoenix.HTML.Safe.to_iodata()
        |> IO.iodata_to_binary()

      refute html =~ "data-duration"
    end
  end
end
