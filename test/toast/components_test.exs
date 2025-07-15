defmodule Toast.ComponentsTest do
  use ExUnit.Case, async: true
  import Phoenix.Component

  alias Toast.Components

  describe "toast component rendering" do
    test "renders basic toast with required attributes" do
      assigns = %{
        toast: %Toast{
          id: "test-123",
          type: :info,
          message: "Test message",
          duration: 6000,
          close_button: true
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "data-toast-id=\"test-123\""
      assert html =~ "data-duration=\"6000\""
      assert html =~ "Test message"
      assert html =~ "role=\"status\""
      assert html =~ "aria-live=\"polite\""
      assert html =~ "toast toast-info"
    end

    test "renders toast with title and description" do
      assigns = %{
        toast: %Toast{
          id: "test-123",
          type: :info,
          message: "Main message",
          title: "Toast Title",
          description: "Additional description"
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "Toast Title"
      assert html =~ "Additional description"
      assert html =~ "Main message"
      assert html =~ "toast-title"
      assert html =~ "toast-description"
    end

    test "renders different toast types with correct classes" do
      types = [:info, :success, :error, :warning, :loading, :default]

      for type <- types do
        assigns = %{
          toast: %Toast{
            id: "test-#{type}",
            type: type,
            message: "#{type} message"
          }
        }

        html = render_component_to_string(~H"<Components.toast {assigns} />")

        assert html =~ "toast-#{type}"
      end
    end

    test "renders toast with action button" do
      assigns = %{
        toast: %Toast{
          id: "test-123",
          type: :info,
          message: "Message with action",
          action: %{
            label: "Undo",
            event: "undo_action"
          }
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "Undo"
      assert html =~ "toast-action"
      assert html =~ "data-toast-action"
    end

    test "renders toast with inline action" do
      assigns = %{
        toast: %Toast{
          id: "test-123",
          type: :info,
          message: "Message with inline action",
          action: %{
            label: "Retry",
            event: "retry_action",
            inline: true
          }
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "Retry"
      assert html =~ "toast-action-inline"
    end

    test "renders toast with custom icon" do
      assigns = %{
        toast: %Toast{
          id: "test-123",
          type: :info,
          message: "Message with custom icon",
          icon: "<svg>custom</svg>"
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "<svg>custom</svg>"
    end

    test "renders toast without close button when disabled" do
      assigns = %{
        toast: %Toast{
          id: "test-123",
          type: :info,
          message: "No close button",
          close_button: false
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      refute html =~ "data-close-toast"
      refute html =~ "toast-close"
    end

    test "renders toast with close button when enabled" do
      assigns = %{
        toast: %Toast{
          id: "test-123",
          type: :info,
          message: "With close button",
          close_button: true
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "data-close-toast"
      assert html =~ "toast-close"
    end

    test "renders important toast with correct attributes" do
      assigns = %{
        toast: %Toast{
          id: "test-123",
          type: :error,
          message: "Important error",
          important: true
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "aria-live=\"assertive\""
    end

    test "renders loading toast with spinner" do
      assigns = %{
        toast: %Toast{
          id: "test-123",
          type: :loading,
          message: "Loading..."
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "toast-loading"
      assert html =~ "animate-spin"
      assert html =~ "Loading..."
    end
  end

  describe "component exports" do
    test "container/1 is exported" do
      assert function_exported?(Components, :container, 1)
    end
  end

  describe "icon rendering" do
    test "renders success icon" do
      assigns = %{
        toast: %Toast{
          id: "test-success",
          type: :success,
          message: "Success message"
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "polyline points=\"20 6 9 17 4 12\""
    end

    test "renders error icon" do
      assigns = %{
        toast: %Toast{
          id: "test-error",
          type: :error,
          message: "Error message"
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "circle cx=\"12\" cy=\"12\" r=\"10\""
      assert html =~ "line x1=\"12\" y1=\"8\" x2=\"12\" y2=\"12\""
    end

    test "renders warning icon" do
      assigns = %{
        toast: %Toast{
          id: "test-warning",
          type: :warning,
          message: "Warning message"
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~
               "M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"
    end

    test "renders info icon" do
      assigns = %{
        toast: %Toast{
          id: "test-info",
          type: :info,
          message: "Info message"
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "circle cx=\"12\" cy=\"12\" r=\"10\""
      assert html =~ "line x1=\"12\" y1=\"16\" x2=\"12\" y2=\"12\""
    end

    test "renders loading icon" do
      assigns = %{
        toast: %Toast{
          id: "test-loading",
          type: :loading,
          message: "Loading message"
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      assert html =~ "M21 12a9 9 0 1 1-6.219-8.56"
      assert html =~ "animate-spin"
    end

    test "renders no icon for default type" do
      assigns = %{
        toast: %Toast{
          id: "test-default",
          type: :default,
          message: "Default message"
        }
      }

      html = render_component_to_string(~H"<Components.toast {assigns} />")

      refute html =~ "toast-icon"
    end
  end

  # Helper function to render a component to string
  defp render_component_to_string(template) do
    template
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end
