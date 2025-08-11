defmodule Toast do
  @moduledoc """
  Server-rendered toast notifications for Phoenix LiveView.

  Toast is a notification system for Phoenix LiveView that works as a drop-in replacement for your
  existing flash messages. It provides three ways to show notifications:

  1. **Toast messages** - Call `Toast.send_toast()` from your LiveView to show rich, interactive notifications
  2. **Pipe operation** - Use `Toast.put_toast()` to pipe toast messages in your socket chain
  3. **Flash messages** - Your existing `put_flash()` calls continue to work, displayed in the same toast style

  ## Installation

  Add `toast` to your dependencies in `mix.exs`:

      def deps do
        [
          {:toast, "~> 0.2.0"}
        ]
      end

  ## Setup

  1. Import the JavaScript hook in your `app.js`:

      # Note: The import path may vary depending on your project structure
      # For assets in the root directory:
      import Toast from "../deps/toast/assets/js/toast.js";

      # For assets in nested folders (e.g., assets/js/app.js):
      import Toast from "../../deps/toast/assets/js/toast.js";

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { Toast }
      });

  2. Import the CSS in your `app.css`:

      /* Note: The import path may vary depending on your project structure */
      /* For assets in the root directory: */
      @import "../deps/toast/assets/css/toast.css";

      /* For assets in nested folders (e.g., assets/css/app.css): */
      @import "../../deps/toast/assets/css/toast.css";

      /* If you are using DaisyUI, exclude their toast component to avoid conflicts: */
      @plugin "../vendor/daisyui" {
        exclude: toast;
      }

  3. Add the toast container to your root layout:

      <Toast.toast_group flash={@flash} />

  ## Basic Usage

  Send toasts from your LiveView:

      def handle_event("save", _params, socket) do
        Toast.send_toast(:success, "Changes saved!")
        {:noreply, socket}
      end

  Or use the pipe-friendly version:

      def handle_event("save", _params, socket) do
        {:noreply,
         socket
         |> assign(:saved, true)
         |> Toast.put_toast(:success, "Changes saved!")}
      end

  ## Toast Types

  - `:info` - Blue informational messages
  - `:success` - Green success messages
  - `:error` - Red error messages
  - `:warning` - Yellow warning messages
  - `:loading` - Loading state with spinner
  - `:default` - Default neutral style

  ## Options

  Configure individual toasts with:

      Toast.send_toast(:success, "Message",
        title: "Success!",
        description: "Additional details",
        duration: 10_000,
        action: %{
          label: "Undo",
          event: "undo_action"
        }
      )

  ## HTML Content

  Toast supports rendering raw HTML in messages, titles, and descriptions using `Phoenix.HTML.raw/1`:

      # Render HTML in message
      Toast.send_toast(:info, Phoenix.HTML.raw("<strong>Important:</strong> Action required"))

      # Render HTML in all fields
      Toast.send_toast(:success, Phoenix.HTML.raw("Payment <em>processed</em>"),
        title: Phoenix.HTML.raw("<strong>Success!</strong>"),
        description: Phoenix.HTML.raw("Transaction ID: <code>TXN-12345</code>")
      )

  **⚠️ Security Warning**: Only use `Phoenix.HTML.raw/1` with trusted content. Never render
  user-generated HTML without proper sanitization as it can lead to XSS vulnerabilities.

  See the documentation for `send_toast/3` for all available options.
  """

  use Phoenix.Component

  defstruct [
    :id,
    :type,
    :message,
    :title,
    :description,
    :duration,
    :action,
    :icon,
    :close_button,
    :position,
    :important
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          type: :info | :success | :error | :warning | :loading | :default,
          message: String.t(),
          title: String.t() | nil,
          description: String.t() | nil,
          duration: integer() | nil,
          action: map() | nil,
          icon: String.t() | nil,
          close_button: boolean(),
          position: atom() | nil,
          important: boolean()
        }

  @doc """
  Renders the toast notification container.

  This is a convenience function component that wraps the Toast.LiveComponent.
  It can be used directly in your templates with the component syntax.

  ## Examples

      <Toast.toast_group
        flash={@flash}
      />

      <Toast.toast_group
        flash={@flash}
        position="top-right"
        theme="dark"
        rich_colors={true}
        max_toasts={5}
        animation_duration={600}
      />

  ## Attributes

  * `:id` - The ID of the toast group container (default: "toast-group")
  * `:flash` - The flash assigns from the socket
  * `:position` - Position of toasts: "top-left", "top-center", "top-right", "bottom-left", "bottom-center", "bottom-right" (default: "bottom-right")
  * `:theme` - Theme: "light" or "dark" (default: "light")
  * `:rich_colors` - Whether to use rich colors for different toast types (default: false)
  * `:max_toasts` - Maximum number of toasts to display (default: 3)
  * `:animation_duration` - Duration of animations in milliseconds (default: 400)
  """
  attr(:id, :string, default: "toast-group")
  attr(:flash, :map, required: false)
  attr(:position, :string, default: "bottom-right")
  attr(:theme, :string, default: "light")
  attr(:rich_colors, :boolean, default: false)
  attr(:max_toasts, :integer, default: 3)
  attr(:animation_duration, :integer, default: 400)

  def toast_group(assigns) do
    ~H"""
      <.live_component
        module={Toast.LiveComponent}
        id={@id}
        flash={@flash}
        position={@position}
        theme={@theme}
        rich_colors={@rich_colors}
        max_toasts={@max_toasts}
        animation_duration={@animation_duration}
      />
    """
  end

  @doc """
  Sends a toast notification to the LiveComponent.

  ## Examples

      Toast.send_toast(:info, "Operation completed!")
      Toast.send_toast(:error, "Something went wrong", title: "Error", duration: 10_000)

  ## HTML Content

  You can render HEEX a template in any field by using the `~H` sigil.
  There is only one requirement when doing so: you **must** make `assigns` available.

  In this example, `assigns` is available via destructuring:

        def handle_event("show_toast", _params, %{assigns: assigns} = socket) do
          Toast.send_toast(:info, ~H"<strong>Bold</strong> text")
        end

  Or you can just create an empty `assigns` map.

        def handle_event("show_toast", _params, socket) do
          assigns = %{}
          Toast.send_toast(:info, ~H"<strong>Bold</strong> text")
        end

  You can also render raw HTML in any text field using `Phoenix.HTML.raw/1`:
  **Security Note**: Only use `Phoenix.HTML.raw/1` with trusted content to avoid XSS and other injection attacks.
  If you use `Phoenix.HTML.raw/1` with dynamic or user input, you can wrap content with `Phoenix.HTML.html_escape/1` to make it safe.

      Toast.send_toast(:info, Phoenix.HTML.raw("<strong>Bold</strong> text"))

      Toast.send_toast(:success, Phoenix.HTML.raw("Check the <a href='/docs'>docs</a>"),
        title: Phoenix.HTML.raw("<em>Success!</em>"),
        # use html_escape to prevent xss vulnerablilites
        description: Phoenix.HTML.raw("Transaction: <code>"<> Phoenix.HTML.html_escape(transaction_value) <>"</code>")
      )
  """
  def send_toast(type, message, opts \\ []) do
    toast = build_toast(type, message, opts)

    Phoenix.LiveView.send_update(self(), Toast.LiveComponent,
      id: "toast-group",
      toast: toast
    )
  end

  @doc """
  Sends a toast notification and returns the socket for piping.

  This is a convenience function for use in pipelines.

  ## Examples

      socket
      |> assign(:user, user)
      |> put_toast(:success, "Profile updated!")
      |> push_navigate(to: ~p"/profile")
  """
  def put_toast(socket, type, message, opts \\ []) do
    send_toast(type, message, opts)
    socket
  end

  @doc """
  Updates an existing toast by ID.

  ## Examples

      Toast.update_toast("toast-123", message: "Updated message", type: :success)
      Toast.update_toast("toast-123", title: "New Title", duration: 10_000)
  """
  def update_toast(toast_id, updates) do
    Phoenix.LiveView.send_update(self(), Toast.LiveComponent,
      id: "toast-group",
      update_toast: %{id: toast_id, updates: updates}
    )
  end

  @doc """
  Clears a specific toast by ID.
  """
  def clear_toast(id) do
    Phoenix.LiveView.send_update(self(), Toast.LiveComponent,
      id: "toast-group",
      clear: id
    )
  end

  @doc """
  Clears all toasts.
  """
  def clear_all_toasts() do
    Phoenix.LiveView.send_update(self(), Toast.LiveComponent,
      id: "toast-group",
      clear_all: true
    )
  end

  defp build_toast(type, message, opts) do
    %__MODULE__{
      id: opts[:id] || generate_id(),
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

  defp generate_id do
    "toast-#{:crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)}"
  end
end
