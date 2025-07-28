defmodule ToastDemoWeb.HomeLive do
  use ToastDemoWeb, :live_view

  alias Toast

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-10">
      <div class="mx-auto max-w-3xl">
        <%!-- Sonner-style header card --%>
        <div class="bg-white rounded-xl border border-gray-200 p-8 mb-12 text-center shadow-sm">
          <h1 class="text-4xl font-bold mb-4">Toast</h1>
          <p class="text-lg text-gray-600 mb-8">
            A toast system for Phoenix LiveView.
          </p>
          <div class="flex gap-3 justify-center mb-6">
            <button
              phx-click="show_toast"
              phx-value-type="default"
              phx-value-message="Toast rendered successfully!"
              class="px-5 py-2.5 bg-black text-white text-sm font-medium rounded-md hover:bg-gray-800 transition-colors"
            >
              Render a toast
            </button>
            <a
              href="https://github.com/dmkenney/toast"
              target="_blank"
              class="px-5 py-2.5 bg-white text-black text-sm font-medium rounded-md border border-gray-300 hover:bg-gray-50 transition-colors inline-flex items-center gap-2"
            >
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                <path
                  fill-rule="evenodd"
                  d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                  clip-rule="evenodd"
                />
              </svg>
              GitHub
            </a>
            <a
              href="https://hex.pm/packages/toast"
              target="_blank"
              class="px-5 py-2.5 bg-white text-black text-sm font-medium rounded-md border border-gray-300 hover:bg-gray-50 transition-colors inline-flex items-center gap-2"
            >
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                <path d="M14.97 2.83l5.51 3.18c.64.37 1.02 1.04 1.02 1.77v6.44c0 .73-.38 1.4-1.02 1.77l-5.51 3.18c-.64.37-1.44.37-2.08 0l-5.51-3.18c-.64-.37-1.02-1.04-1.02-1.77V7.78c0-.73.38-1.4 1.02-1.77l5.51-3.18c.64-.37 1.44-.37 2.08 0z" />
              </svg>
              Hex
            </a>
          </div>
          <a
            href="https://hexdocs.pm/toast/readme.html"
            target="_blank"
            class="text-sm text-gray-500 underline hover:text-gray-700"
          >
            Documentation
          </a>
        </div>

        <div class="space-y-8">
          <%!-- Basic Toast Types --%>
          <section>
            <h2 class="text-2xl font-semibold mb-4">Toast Types</h2>
            <div class="grid grid-cols-2 sm:grid-cols-3 gap-4">
              <button
                phx-click="show_toast"
                phx-value-type="default"
                phx-value-message="This is a default toast"
                class="px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors"
              >
                Default
              </button>

              <button
                phx-click="show_toast"
                phx-value-type="success"
                phx-value-message="Operation completed successfully!"
                class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors"
              >
                Success
              </button>

              <button
                phx-click="show_toast"
                phx-value-type="error"
                phx-value-message="Something went wrong. Please try again."
                class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors"
              >
                Error
              </button>

              <button
                phx-click="show_toast"
                phx-value-type="warning"
                phx-value-message="Please review your input before continuing."
                class="px-4 py-2 bg-yellow-600 text-white rounded-md hover:bg-yellow-700 transition-colors"
              >
                Warning
              </button>

              <button
                phx-click="show_toast"
                phx-value-type="info"
                phx-value-message="New features are available in your account."
                class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
              >
                Info
              </button>

              <button
                phx-click="show_loading"
                class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors"
              >
                Loading
              </button>
            </div>
          </section>

          <%!-- Toast with Title and Description --%>
          <section>
            <h2 class="text-2xl font-semibold mb-4">Rich Content</h2>
            <div class="grid grid-cols-2 sm:grid-cols-3 gap-4">
              <button
                phx-click="show_toast"
                phx-value-type="success"
                phx-value-title="Upload Complete"
                phx-value-message="Your files have been uploaded successfully."
                class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors"
              >
                With Title
              </button>

              <button
                phx-click="show_toast_with_action"
                class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors"
              >
                With Action Button
              </button>

              <button
                phx-click="show_toast_with_inline_action"
                class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors"
              >
                With Inline Action
              </button>
            </div>
          </section>

          <%!-- Positions --%>
          <section>
            <h2 class="text-2xl font-semibold mb-4">Positions</h2>
            <div class="grid grid-cols-2 sm:grid-cols-3 gap-4">
              <button
                phx-click="change_position"
                phx-value-position="top-left"
                class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors"
              >
                Top Left
              </button>

              <button
                phx-click="change_position"
                phx-value-position="top-center"
                class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors"
              >
                Top Center
              </button>

              <button
                phx-click="change_position"
                phx-value-position="top-right"
                class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors"
              >
                Top Right
              </button>

              <button
                phx-click="change_position"
                phx-value-position="bottom-left"
                class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors"
              >
                Bottom Left
              </button>

              <button
                phx-click="change_position"
                phx-value-position="bottom-center"
                class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors"
              >
                Bottom Center
              </button>

              <button
                phx-click="change_position"
                phx-value-position="bottom-right"
                class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors"
              >
                Bottom Right
              </button>
            </div>
            <p class="text-sm text-gray-500 mt-2">
              Click any button to change the toast position
            </p>
          </section>

          <%!-- Theme Toggle --%>
          <section>
            <h2 class="text-2xl font-semibold mb-4">Theme</h2>
            <div class="flex gap-4">
              <button
                phx-click="change_theme"
                phx-value-theme="light"
                class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition-colors"
              >
                Light Theme
              </button>

              <button
                phx-click="change_theme"
                phx-value-theme="dark"
                class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition-colors"
              >
                Dark Theme
              </button>

              <button
                phx-click="toggle_rich_colors"
                class={"px-4 py-2 rounded-md transition-colors " <> if assigns[:rich_colors], do: "bg-purple-600 text-white hover:bg-purple-700", else: "bg-gray-200 text-gray-800 hover:bg-gray-300"}
              >
                Rich Colors {if assigns[:rich_colors], do: "ON", else: "OFF"}
              </button>
            </div>
            <p class="text-sm text-gray-500 mt-2">
              Click to toggle between light and dark themes, or enable/disable rich colors
            </p>
          </section>

          <%!-- Update Toast --%>
          <section>
            <h2 class="text-2xl font-semibold mb-4">Update Toast</h2>
            <div class="flex gap-4">
              <button
                phx-click="test_update"
                class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors"
              >
                Test Update
              </button>
            </div>
            <p class="text-sm text-gray-500 mt-2">
              Creates a toast then updates it twice within 3 seconds
            </p>
          </section>

          <%!-- Async Operations --%>
          <section>
            <h2 class="text-2xl font-semibold mb-4">Async Operations</h2>
            <div class="flex gap-4">
              <button
                phx-click="simulate_async"
                phx-value-result="success"
                class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors"
              >
                Async (Success)
              </button>

              <button
                phx-click="simulate_async"
                phx-value-result="error"
                class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors"
              >
                Async (Error)
              </button>
            </div>
            <p class="text-sm text-gray-500 mt-2">
              Shows loading state, then transitions to success/error
            </p>
          </section>

          <%!-- Custom Duration --%>
          <section>
            <h2 class="text-2xl font-semibold mb-4">Custom Duration</h2>
            <div class="flex gap-4">
              <button
                phx-click="show_toast"
                phx-value-type="default"
                phx-value-message="This toast lasts 1 second"
                phx-value-duration="1000"
                class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition-colors"
              >
                1 Second
              </button>

              <button
                phx-click="show_toast"
                phx-value-type="default"
                phx-value-message="This toast lasts 10 seconds"
                phx-value-duration="10000"
                class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition-colors"
              >
                10 Seconds
              </button>

              <button
                phx-click="show_toast"
                phx-value-type="default"
                phx-value-message="This toast stays until dismissed"
                phx-value-duration="infinity"
                class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition-colors"
              >
                Persistent
              </button>
            </div>
          </section>

          <%!-- Animation Speed --%>
          <section>
            <h2 class="text-2xl font-semibold mb-4">Animation Speed</h2>
            <div class="flex gap-4">
              <button
                phx-click="change_animation_speed"
                phx-value-duration="200"
                class={"px-4 py-2 rounded-md transition-colors " <> if assigns[:animation_duration] == 200, do: "bg-indigo-600 text-white hover:bg-indigo-700", else: "bg-gray-200 text-gray-800 hover:bg-gray-300"}
              >
                Short (200ms)
              </button>

              <button
                phx-click="change_animation_speed"
                phx-value-duration="400"
                class={"px-4 py-2 rounded-md transition-colors " <> if assigns[:animation_duration] == 400, do: "bg-indigo-600 text-white hover:bg-indigo-700", else: "bg-gray-200 text-gray-800 hover:bg-gray-300"}
              >
                Normal (400ms)
              </button>

              <button
                phx-click="change_animation_speed"
                phx-value-duration="800"
                class={"px-4 py-2 rounded-md transition-colors " <> if assigns[:animation_duration] == 800, do: "bg-indigo-600 text-white hover:bg-indigo-700", else: "bg-gray-200 text-gray-800 hover:bg-gray-300"}
              >
                Long (800ms)
              </button>
            </div>
            <p class="text-sm text-gray-500 mt-2">
              Change the animation speed for all toasts
            </p>
          </section>

          <%!-- Regular Flash Messages --%>
          <section>
            <h2 class="text-2xl font-semibold mb-4">Regular Flash Messages</h2>
            <div class="grid grid-cols-2 sm:grid-cols-3 gap-4">
              <button
                phx-click="show_flash"
                phx-value-type="info"
                phx-value-message="This is a flash info message"
                class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
              >
                Flash Info
              </button>

              <button
                phx-click="show_flash"
                phx-value-type="success"
                phx-value-message="Flash success message!"
                class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors"
              >
                Flash Success
              </button>

              <button
                phx-click="show_flash"
                phx-value-type="error"
                phx-value-message="Flash error message"
                class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors"
              >
                Flash Error
              </button>

              <button
                phx-click="show_flash"
                phx-value-type="warning"
                phx-value-message="Flash warning message"
                class="px-4 py-2 bg-yellow-600 text-white rounded-md hover:bg-yellow-700 transition-colors"
              >
                Flash Warning
              </button>
            </div>
            <p class="text-sm text-gray-500 mt-2">
              These use regular Phoenix flash messages via put_flash()
            </p>
          </section>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       position: "bottom-right",
       theme: "light",
       rich_colors: true,
       animation_duration: 400,
       current_path: ~p"/"
     )}
  end

  def handle_event("show_toast", params, socket) do
    type = String.to_atom(params["type"] || "default")
    message = params["message"]
    title = params["title"]

    duration =
      case params["duration"] do
        "infinity" -> 0
        d when is_binary(d) -> String.to_integer(d)
        _ -> 4000
      end

    opts = [duration: duration]
    opts = if title, do: Keyword.put(opts, :title, title), else: opts

    Toast.send_toast(type, message, opts)

    {:noreply, socket}
  end

  def handle_event("show_flash", params, socket) do
    type = String.to_atom(params["type"])
    message = params["message"]

    # Clear any existing flash of this type first
    socket = clear_flash(socket, type)

    # Then set the new flash - this ensures it's treated as new
    {:noreply, socket |> put_flash(type, message)}
  end

  def handle_event("show_loading", _params, socket) do
    id = "loading-#{System.unique_integer([:positive])}"

    Toast.send_toast(:loading, "Loading data...", id: id)

    {:noreply, socket}
  end

  def handle_event("show_toast_with_action", _params, socket) do
    Toast.send_toast(:success, "File uploaded",
      title: "Upload Complete",
      action: %{
        label: "View",
        event: "file_view_clicked"
      }
    )

    {:noreply, socket}
  end

  def handle_event("show_toast_with_inline_action", _params, socket) do
    Toast.send_toast(:default, "Event has been created",
      action: %{
        label: "Undo",
        event: "undo_clicked",
        inline: true
      }
    )

    {:noreply, socket}
  end

  def handle_event("file_view_clicked", _params, socket) do
    Toast.send_toast(:info, "View action clicked!")
    {:noreply, socket}
  end

  def handle_event("undo_clicked", _params, socket) do
    Toast.send_toast(:info, "Action undone!")
    {:noreply, socket}
  end

  def handle_event("change_position", %{"position" => position}, socket) do
    socket = assign(socket, position: position)
    Toast.send_toast(:info, "Position changed to #{position}")

    {:noreply, socket}
  end

  def handle_event("change_theme", %{"theme" => theme}, socket) do
    socket = assign(socket, theme: theme)
    Toast.send_toast(:info, "Theme changed to #{theme}")

    {:noreply, socket}
  end

  def handle_event("toggle_rich_colors", _params, socket) do
    rich_colors = !socket.assigns.rich_colors
    socket = assign(socket, rich_colors: rich_colors)
    status = if rich_colors, do: "enabled", else: "disabled"
    Toast.send_toast(:info, "Rich colors #{status}")

    {:noreply, socket}
  end

  def handle_event("change_animation_speed", %{"duration" => duration}, socket) do
    duration = String.to_integer(duration)
    socket = assign(socket, animation_duration: duration)
    Toast.send_toast(:info, "Animation speed changed to #{duration}ms")

    {:noreply, socket}
  end

  def handle_event("dismiss_all", _params, socket) do
    Toast.clear_all_toasts()
    {:noreply, socket}
  end

  def handle_event("simulate_async", %{"result" => result}, socket) do
    id = "async-#{System.unique_integer([:positive])}"

    Toast.send_toast(:loading, "Processing...", id: id, duration: 0)

    # Simulate async operation
    Process.send_after(self(), {:async_result, id, result}, 2000)

    {:noreply, socket}
  end

  def handle_event("test_update", _params, socket) do
    toast_id = "update-test-#{System.unique_integer([:positive])}"

    # Create initial toast
    Toast.send_toast(:info, "Initial message",
      id: toast_id,
      title: "Test Toast",
      duration: 10_000
    )

    # Schedule updates
    Process.send_after(self(), {:update_toast_test, toast_id, 1}, 1500)
    Process.send_after(self(), {:update_toast_test, toast_id, 2}, 3000)

    {:noreply, socket}
  end

  # Handle flash clearing from the toast component
  def handle_event("lv:clear-flash", %{"key" => key}, socket) do
    {:noreply, clear_flash(socket, String.to_existing_atom(key))}
  end

  def handle_info({:file_view_clicked, _params}, socket) do
    Toast.send_toast(:info, "View action clicked!")
    {:noreply, socket}
  end

  def handle_info({:undo_clicked, _params}, socket) do
    Toast.send_toast(:info, "Action undone!")
    {:noreply, socket}
  end

  def handle_info({:async_result, id, "success"}, socket) do
    # Clear the loading toast
    Toast.clear_toast(id)

    # Show success toast
    Toast.send_toast(:success, "Operation completed!")

    {:noreply, socket}
  end

  def handle_info({:async_result, id, "error"}, socket) do
    # Clear the loading toast  
    Toast.clear_toast(id)

    # Show error toast
    Toast.send_toast(:error, "Operation failed!")

    {:noreply, socket}
  end

  def handle_info({:update_toast_test, toast_id, 1}, socket) do
    # First update: change message and type
    Toast.send_toast(:info, "Updated message!",
      id: toast_id,
      title: "Updated Title"
    )

    {:noreply, socket}
  end

  def handle_info({:update_toast_test, toast_id, 2}, socket) do
    # Second update: change to success with different message
    Toast.send_toast(:success, "Final update - Success!",
      id: toast_id,
      title: "Complete",
      duration: 5_000
    )

    {:noreply, socket}
  end
end
