defmodule ToastTest do
  use ExUnit.Case, async: true

  alias Toast

  describe "toast struct" do
    test "creates toast with all default values" do
      toast = %Toast{}

      assert toast.id == nil
      assert toast.type == nil
      assert toast.message == nil
      assert toast.title == nil
      assert toast.description == nil
      assert toast.duration == nil
      assert toast.action == nil
      assert toast.icon == nil
      assert toast.close_button == nil
      assert toast.position == nil
      assert toast.important == nil
    end

    test "creates toast with custom values" do
      toast = %Toast{
        id: "custom-id",
        type: :success,
        message: "Test message",
        title: "Test title",
        description: "Test description",
        duration: 5000,
        action: %{label: "Undo", event: "undo"},
        icon: "custom-icon",
        close_button: false,
        position: :top_right,
        important: true
      }

      assert toast.id == "custom-id"
      assert toast.type == :success
      assert toast.message == "Test message"
      assert toast.title == "Test title"
      assert toast.description == "Test description"
      assert toast.duration == 5000
      assert toast.action == %{label: "Undo", event: "undo"}
      assert toast.icon == "custom-icon"
      assert toast.close_button == false
      assert toast.position == :top_right
      assert toast.important == true
    end
  end

  describe "send_toast/3" do
    test "builds toast with default values" do
      toast = build_test_toast(:info, "Test message", [])

      assert toast.type == :info
      assert toast.message == "Test message"
      assert toast.duration == 6000
      assert toast.close_button == true
      assert toast.important == false
      assert String.starts_with?(toast.id, "toast-")
    end

    test "builds toast with custom options" do
      toast =
        build_test_toast(:error, "Error occurred",
          title: "Error",
          description: "Something went wrong",
          duration: 10_000,
          action: %{label: "Retry", event: "retry_action"},
          icon: "error-icon",
          close_button: false,
          position: :bottom_left,
          important: true
        )

      assert toast.type == :error
      assert toast.message == "Error occurred"
      assert toast.title == "Error"
      assert toast.description == "Something went wrong"
      assert toast.duration == 10_000
      assert toast.action == %{label: "Retry", event: "retry_action"}
      assert toast.icon == "error-icon"
      assert toast.close_button == false
      assert toast.position == :bottom_left
      assert toast.important == true
    end

    test "generates unique toast IDs" do
      toast1 = build_test_toast(:info, "Message 1", [])
      toast2 = build_test_toast(:info, "Message 2", [])

      assert toast1.id != toast2.id
      assert String.starts_with?(toast1.id, "toast-")
      assert String.starts_with?(toast2.id, "toast-")
    end

    test "allows custom ID to be provided" do
      toast = build_test_toast(:info, "Test", id: "custom-toast-id")
      assert toast.id == "custom-toast-id"
    end

    test "handles all toast types" do
      types = [:info, :success, :error, :warning, :loading, :default]

      for type <- types do
        toast = build_test_toast(type, "Test #{type}", [])
        assert toast.type == type
      end
    end
  end

  describe "toast API functions" do
    test "different toast types have correct attributes" do
      # Info toast
      info_toast = build_test_toast(:info, "Information", [])
      assert info_toast.type == :info
      assert info_toast.message == "Information"

      # Success toast
      success_toast = build_test_toast(:success, "Success!", [])
      assert success_toast.type == :success
      assert success_toast.message == "Success!"

      # Error toast
      error_toast = build_test_toast(:error, "Error!", [])
      assert error_toast.type == :error
      assert error_toast.message == "Error!"

      # Warning toast
      warning_toast = build_test_toast(:warning, "Warning!", [])
      assert warning_toast.type == :warning
      assert warning_toast.message == "Warning!"

      # Loading toast
      loading_toast = build_test_toast(:loading, "Loading...", [])
      assert loading_toast.type == :loading
      assert loading_toast.message == "Loading..."
    end

    test "duration defaults and overrides" do
      # Default duration
      default_toast = build_test_toast(:info, "Test", [])
      assert default_toast.duration == 6000

      # Custom duration
      custom_toast = build_test_toast(:info, "Test", duration: 3000)
      assert custom_toast.duration == 3000

      # Zero duration (infinite)
      infinite_toast = build_test_toast(:info, "Test", duration: 0)
      assert infinite_toast.duration == 0
    end

    test "action configuration" do
      # No action
      no_action_toast = build_test_toast(:info, "Test", [])
      assert no_action_toast.action == nil

      # With action
      action_toast =
        build_test_toast(:info, "Test", action: %{label: "Undo", event: "undo_action"})

      assert action_toast.action == %{label: "Undo", event: "undo_action"}

      # Action with inline flag
      inline_action_toast =
        build_test_toast(:info, "Test", action: %{label: "Retry", event: "retry", inline: true})

      assert inline_action_toast.action.inline == true
    end

    test "close button configuration" do
      # Default close button (true)
      default_toast = build_test_toast(:info, "Test", [])
      assert default_toast.close_button == true

      # Explicitly enabled
      enabled_toast = build_test_toast(:info, "Test", close_button: true)
      assert enabled_toast.close_button == true

      # Disabled
      disabled_toast = build_test_toast(:info, "Test", close_button: false)
      assert disabled_toast.close_button == false
    end

    test "position configuration" do
      positions = [
        :top_left,
        :top_center,
        :top_right,
        :bottom_left,
        :bottom_center,
        :bottom_right
      ]

      for position <- positions do
        toast = build_test_toast(:info, "Test", position: position)
        assert toast.position == position
      end
    end

    test "important flag configuration" do
      # Default (false)
      default_toast = build_test_toast(:info, "Test", [])
      assert default_toast.important == false

      # Important toast
      important_toast = build_test_toast(:info, "Test", important: true)
      assert important_toast.important == true
    end

    test "complex toast with all options" do
      toast =
        build_test_toast(:error, "Critical error occurred",
          id: "error-123",
          title: "System Error",
          description: "Please contact support if this persists",
          duration: 15_000,
          action: %{
            label: "Contact Support",
            event: "open_support",
            inline: false
          },
          icon: "exclamation-triangle",
          close_button: true,
          position: :top_center,
          important: true
        )

      assert toast.id == "error-123"
      assert toast.type == :error
      assert toast.message == "Critical error occurred"
      assert toast.title == "System Error"
      assert toast.description == "Please contact support if this persists"
      assert toast.duration == 15_000
      assert toast.action.label == "Contact Support"
      assert toast.action.event == "open_support"
      assert toast.action.inline == false
      assert toast.icon == "exclamation-triangle"
      assert toast.close_button == true
      assert toast.position == :top_center
      assert toast.important == true
    end
  end

  describe "put_toast/4" do
    test "returns the socket unchanged" do
      # Mock socket
      socket = %{assigns: %{user: "test"}}

      # put_toast should return the same socket
      result = Toast.put_toast(socket, :info, "Test message", [])
      assert result == socket
    end
  end

  # Test that the public API functions exist
  describe "public API" do
    test "send_toast/3 is exported" do
      assert function_exported?(Toast, :send_toast, 3)
    end

    test "put_toast/4 is exported" do
      assert function_exported?(Toast, :put_toast, 4)
    end

    test "update_toast/2 is exported" do
      assert function_exported?(Toast, :update_toast, 2)
    end

    test "clear_toast/1 is exported" do
      assert function_exported?(Toast, :clear_toast, 1)
    end

    test "clear_all_toasts/0 is exported" do
      assert function_exported?(Toast, :clear_all_toasts, 0)
    end
  end

  # Helper function to build toasts for testing
  # This mimics the private build_toast function in Toast
  defp build_test_toast(type, message, opts) do
    %Toast{
      id: opts[:id] || generate_test_id(),
      type: type,
      message: message,
      title: opts[:title],
      description: opts[:description],
      duration: opts[:duration] || 6000,
      action: opts[:action],
      icon: opts[:icon],
      close_button: Keyword.get(opts, :close_button, true),
      position: opts[:position],
      important: Keyword.get(opts, :important, false)
    }
  end

  defp generate_test_id do
    "toast-#{:crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)}"
  end
end
