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

  These steps match a new Phoenix 1.8 app with the default `assets/js/app.js`
  and `assets/css/app.css`.

  ### JavaScript

  In `assets/js/app.js`, import the hook and add it to your existing LiveSocket
  hooks. Keep the other options as they are. On Phoenix 1.7, add `hooks: {Toast}`.

  ```javascript
  import Toast from "../../deps/toast/assets/js/toast.js"

  const liveSocket = new LiveSocket("/live", Socket, {
    longPollFallbackMs: 2500,
    params: {_csrf_token: csrfToken},
    hooks: {...colocatedHooks, Toast},
  })
  ```

  ### CSS

  In `assets/css/app.css`, import the stylesheet after the Tailwind import. If you
  use daisyUI, add `exclude: toast;` to your existing daisyUI plugin block, since
  its `toast` class clashes with Toast's.

  ```css
  @import "tailwindcss" source(none);
  @import "../../deps/toast/assets/css/toast.css";

  @plugin "daisyui/packages/bundle/daisyui" {
    themes: false;
    exclude: toast;
  }
  ```

  ### Layout

  `toast_group/1` renders a LiveComponent, so it must be inside a LiveView. Don't
  put it in `root.html.heex`: every page then fails with
  `cannot convert component Toast.LiveComponent ... to HTML`.

  On Phoenix 1.8, replace `<.flash_group flash={@flash} />` in `Layouts.app`
  (`lib/my_app_web/components/layouts.ex`). Add a `live` attr so controller
  templates, which aren't LiveViews, can render a plain flash list instead:

  ```elixir
  attr :live, :boolean, default: true, doc: "set to false in controller templates"
  ```

  ```heex
  <Toast.toast_group :if={@live} flash={@flash} connection_toasts={true} />
  <Toast.flash_group :if={!@live} flash={@flash} />
  ```

  Controller templates then use `<Layouts.app flash={@flash} live={false}>`.
  `connection_toasts` replaces the `#client-error` and `#server-error` flashes
  from Phoenix's `flash_group`.

  On Phoenix 1.7, put the same markup in `app.html.heex`, using
  `assigns[:socket]` in place of `@live`, since only LiveViews have a socket.

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

  `send_toast/3` and `put_toast/4` take the same options:

      Toast.send_toast(:success, "Message",
        id: "my-toast",
        title: "Success!",
        description: "Additional details",
        duration: 10_000,
        action: %{
          label: "Undo",
          event: "undo_action",
          params: %{id: 1}
        }
      )

  * `:id` - Toast id, for `update_toast/2` and `clear_toast/1` (default: random)
  * `:title` - Text above the message
  * `:description` - Text below the message
  * `:duration` - Auto-dismiss time in milliseconds. `0` keeps the toast open (default: 6000)
  * `:close_button` - Show the close button (default: true)
  * `:important` - Use `aria-live="assertive"` (default: false)
  * `:icon` - Custom SVG icon HTML
  * `:action` - Map with `:label`, `:event`, optional `:params` and `:inline`

  Clicking an action button closes the toast and sends `{event, params}` to the
  LiveView. The event is an atom and `params` has string keys:

      def handle_info({:undo_action, %{"id" => id}}, socket) do
        {:noreply, socket}
      end

  Flash messages from `put_flash/3` don't auto-dismiss. They stay until the user
  closes them.

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

      <Toast.toast_group flash={@flash} expanded={true} />

  ## Attributes

  * `:id` - DOM id of the toast list. The connection toasts use `"<id>-client-error"` and
    `"<id>-server-error"` (default: "toast-group"). Render one toast group per page.
  * `:flash` - The flash assigns from the socket
  * `:position` - Position of toasts: "top-left", "top-center", "top-right", "bottom-left", "bottom-center", "bottom-right" (default: "bottom-right")
  * `:theme` - Theme: "light", "dark", or "system" to follow the page's `data-theme`/`.dark`, then the OS color scheme (default: "light")
  * `:rich_colors` - Whether to use rich colors for different toast types (default: false)
  * `:max_toasts` - Maximum number of toasts to display (default: 3)
  * `:animation_duration` - Duration of animations in milliseconds (default: 400)
  * `:connection_toasts` - Show an error toast while the LiveView is disconnected (default: false).
    Replaces the `#client-error` and `#server-error` flashes from Phoenix's generated layouts,
    so remove those when you turn this on.
  * `:client_error_title` - Title shown when the client loses its connection (default: "We can't find the internet")
  * `:client_error_message` - Message shown when the client loses its connection (default: "Attempting to reconnect")
  * `:server_error_title` - Title shown when the server crashes (default: "Something went wrong!")
  * `:server_error_message` - Message shown when the server crashes (default: "Hang in there while we get back on track")
  * `:expanded` - Always show toasts expanded instead of stacked. When `false`, toasts
    stack and expand on hover (default: false)

  To translate the connection toasts, pass gettext strings:

      <Toast.toast_group
        flash={@flash}
        connection_toasts={true}
        client_error_title={gettext("We can't find the internet")}
        client_error_message={gettext("Attempting to reconnect")}
      />
  """
  attr(:id, :string, default: "toast-group")
  attr(:flash, :map, required: false)
  attr(:position, :string, default: "bottom-right")
  attr(:theme, :string, default: "light")
  attr(:rich_colors, :boolean, default: false)
  attr(:max_toasts, :integer, default: 3)
  attr(:animation_duration, :integer, default: 400)
  attr(:connection_toasts, :boolean, default: false)
  attr(:client_error_title, :string, default: "We can't find the internet")
  attr(:client_error_message, :string, default: "Attempting to reconnect")
  attr(:server_error_title, :string, default: "Something went wrong!")
  attr(:server_error_message, :string, default: "Hang in there while we get back on track")
  attr(:expanded, :boolean, default: false)

  def toast_group(assigns) do
    ~H"""
      <.live_component
        module={Toast.LiveComponent}
        id="toast-group"
        dom_id={@id}
        flash={@flash}
        position={@position}
        theme={@theme}
        rich_colors={@rich_colors}
        max_toasts={@max_toasts}
        animation_duration={@animation_duration}
        connection_toasts={@connection_toasts}
        client_error_title={@client_error_title}
        client_error_message={@client_error_message}
        server_error_title={@server_error_title}
        server_error_message={@server_error_message}
        expanded={@expanded}
      />
    """
  end

  @doc """
  Renders flash messages in Toast's style on pages that are not LiveViews.

  `toast_group/1` needs a LiveView, so controller templates use this instead.
  Pass the same `position`, `theme` and `rich_colors` as your `toast_group/1`
  so both look the same. Flash messages here don't auto-dismiss and the close
  button does nothing, since the JavaScript hook only runs in a LiveView.

  ## Examples

      <Toast.flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true)
  attr(:position, :string, default: "bottom-right")
  attr(:theme, :string, default: "light")
  attr(:rich_colors, :boolean, default: false)

  def flash_group(assigns) do
    ~H"""
    <div class={"live-toast-group toast-position-#{@position}"}>
      <Toast.Components.flash_group
        flash={@flash}
        position={@position}
        theme={@theme}
        rich_colors={@rich_colors}
      />
    </div>
    """
  end

  @doc """
  Sends a toast notification to the LiveComponent.

  ## Examples

      Toast.send_toast(:info, "Operation completed!")
      Toast.send_toast(:error, "Something went wrong", title: "Error", duration: 10_000)

  ## HTML Content

  You can render raw HTML in any text field using `Phoenix.HTML.raw/1`:

      Toast.send_toast(:info, Phoenix.HTML.raw("<strong>Bold</strong> text"))
      
      Toast.send_toast(:success, Phoenix.HTML.raw("Check the <a href='/docs'>docs</a>"),
        title: Phoenix.HTML.raw("<em>Success!</em>"),
        description: Phoenix.HTML.raw("Transaction: <code>ABC-123</code>")
      )

  **Security Note**: Only use `Phoenix.HTML.raw/1` with trusted content to avoid XSS attacks.
  """
  def send_toast(type, message, opts \\ []) do
    toast = build_toast(type, message, opts)

    Phoenix.LiveView.send_update(self(), Toast.LiveComponent,
      id: "toast-group",
      toast: toast
    )
  end

  # Flash keys starting with this prefix hold toasts added with put_toast/4.
  @doc false
  def flash_prefix, do: "__toast__:"

  @doc """
  Puts a toast in the socket's flash and returns the socket for piping.

  Accepts the same options as `send_toast/3`. Because the toast is stored in the
  flash, it is still shown after `push_navigate/2` or `redirect/2`, like `put_flash/3`.

  On `redirect/2` the flash travels in a cookie, which browsers drop above about
  4KB. A large toast can push it over that limit, and then no flash messages are
  shown on the next page. Keep toasts small when redirecting.

  Called from a LiveComponent, the toast is shown right away but is not carried
  across navigation. Call `put_toast/4` in the parent LiveView for that.

  ## Examples

      socket
      |> assign(:user, user)
      |> put_toast(:success, "Profile updated!")
      |> push_navigate(to: ~p"/profile")
  """
  def put_toast(socket, type, message, opts \\ []) do
    # A LiveComponent's flash only reaches the LiveView when that callback
    # navigates, and it is never cleared otherwise, so a toast kept there would
    # come back on the component's next navigation. Send it right away instead.
    if match?(%Phoenix.LiveComponent.CID{}, socket.assigns[:myself]) do
      send_toast(type, message, opts)
      socket
    else
      put_flash_toast(socket, type, message, opts)
    end
  end

  defp put_flash_toast(socket, type, message, opts) do
    # Store a plain map so the flash can go through the session cookie on redirect.
    toast =
      type
      |> build_toast(message, opts)
      |> Map.from_struct()
      |> Map.reject(fn {_key, value} -> is_nil(value) end)

    # One key per toast, so a navigation only carries the toasts put in that
    # callback. The counter keeps their order.
    key = flash_prefix() <> Integer.to_string(System.unique_integer([:positive, :monotonic]))

    if Phoenix.LiveView.connected?(socket) do
      socket
      |> clear_dead_render_copy(toast)
      |> Phoenix.LiveView.put_flash(key, toast)
    else
      Phoenix.LiveView.put_flash(socket, key, Map.put(toast, :dead_render, true))
    end
  end

  # The flash from the dead render is handed to the connected mount, where a
  # put_toast/4 in mount/3 runs again, so drop the dead render's copy.
  defp clear_dead_render_copy(socket, toast) do
    content = Map.delete(toast, :id)

    socket.assigns.flash
    |> Enum.filter(fn {key, value} ->
      is_binary(key) and String.starts_with?(key, flash_prefix()) and
        is_map(value) and value[:dead_render] == true and
        Map.drop(value, [:id, :dead_render]) == content
    end)
    |> Enum.reduce(socket, fn {key, _}, socket -> Phoenix.LiveView.clear_flash(socket, key) end)
  end

  @doc """
  Updates an existing toast by ID.

  `updates` is a keyword list of toast fields (`:type`, `:message`, `:title`,
  `:description`, `:duration`, `:action`, `:icon`, `:close_button`, `:important`).
  The toast is re-rendered in place. A new `:duration` restarts its timer.
  Unknown fields are ignored, and an ID that isn't showing is a no-op.

  ## Examples

      # duration: 0 keeps the loading toast open until it is updated
      Toast.send_toast(:loading, "Uploading...", id: "upload", duration: 0)
      Toast.update_toast("upload", type: :success, message: "Upload complete", duration: 3000)

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
