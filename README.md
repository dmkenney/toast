# Toast

Server-rendered toast notifications for Phoenix LiveView.

**[View Demo](https://toast.dkenney.com)** - See Toast in action with interactive examples.

## What is Toast?

Toast is a notification system for Phoenix LiveView that works as a drop-in replacement for your existing `flash` messages. It provides three ways to show notifications:

1. **Toast messages** - Call `Toast.send_toast()` from your LiveView to show rich, interactive notifications
2. **Pipe operation** - Use `Toast.put_toast()` to pipe toast messages in your socket chain
3. **Flash messages** - Your existing `put_flash()` calls continue to work, displayed in the same toast style

## Features

- 📚 **Stackable toasts** - Unlike flash messages, display multiple toasts simultaneously
- 🔄 **Drop-in replacement** - Your existing `put_flash()` calls render as beautiful toasts  
- ✨ **Beautiful by default** - Inspired by Sonner's elegant design, looks great out of the box
- 🎨 **Framework agnostic styling** - Ships with CSS, works with any CSS framework or custom styles
- ⚙️ **Highly customizable** - Themes, positions, animations, icons, actions - all configurable
- 🚀 **Server-controlled** - Full power of LiveView, no client-side state to manage
- 📦 **Self-contained** - CSS and JS included, no build step or npm required
- 🎯 **Zero configuration** - Works out of the box with sensible defaults
- 🪶 **Tiny footprint** - Single JS hook, no external dependencies

## Installation

Add `toast` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:toast, "~> 0.2.0"}
  ]
end
```

## Setup

1. Import the JavaScript hook in your `app.js`:

```javascript
// Note: The import path may vary depending on your project structure
// For assets in the root directory:
import Toast from "../deps/toast/assets/js/toast.js";

// For assets in nested folders (e.g., assets/js/app.js):
import Toast from "../../deps/toast/assets/js/toast.js";

// Add to your LiveSocket hooks
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { Toast }
});
```

2. Import the CSS in your `app.css`:

```css
/* Note: The import path may vary depending on your project structure */
/* For assets in the root directory: */
@import "../deps/toast/assets/css/toast.css";

/* For assets in nested folders (e.g., assets/css/app.css): */
@import "../../deps/toast/assets/css/toast.css";
```
If you are using Daisy UI, you should exclude the Toast component to avoid style conflicts
```css
@plugin "../vendor/daisyui" {
    exclude: toast;
}
```

3. Add the toast container to your root layout (`root.html.heex`):

```heex
<Toast.toast_group flash={@flash} />
```

## Basic Usage

### In LiveView

Send toasts from your LiveView event handlers:

```elixir
def handle_event("save", _params, socket) do
  {:noreply, 
   socket
   |> assign(:saved, true)
   |> Toast.put_toast(:success, "Changes saved!")}
end

def handle_event("delete", _params, socket) do
  {:noreply,
   socket
   |> Toast.put_toast(:error, "Failed to delete", duration: 5000)}
end

# put_toast is stored in the flash, so it is still shown after navigating
def handle_event("create", _params, socket) do
  {:noreply,
   socket
   |> Toast.put_toast(:success, "Item created!")
   |> push_navigate(to: ~p"/items")}
end

# Or without piping (shown on the current LiveView only)
def handle_event("notify", _params, socket) do
  Toast.send_toast(:info, "Notification sent!")
  {:noreply, socket}
end
```

Notes on `put_toast` and navigation:
- On `redirect/2` the flash travels in a cookie, which browsers drop above about 4KB. A large toast can push it over, and then no flash messages show on the next page.
- From a LiveComponent, `put_toast` shows the toast right away but doesn't carry it across navigation. Call it in the parent LiveView for that.

### Flash Messages

Toast continues to render your app's flash messages in the same style as toasts:

```elixir
# In a LiveView
def handle_event("save", _params, socket) do
  {:noreply, put_flash(socket, :success, "Settings updated!")}
end

# In a controller
def create(conn, params) do
  conn
  |> put_flash(:success, "Item created successfully!")
  |> redirect(to: ~p"/items")
end
```

## Toast Types

Toast comes with 6 built-in types, each with its own icon and color:

- `:info` - Blue informational messages
- `:success` - Green success messages
- `:error` - Red error messages
- `:warning` - Yellow warning messages
- `:loading` - Loading state with spinner
- `:default` - Default neutral style

## Configuration Options

### Toast Container Options

Configure the toast container with these attributes:

```heex
<Toast.toast_group
  flash={@flash}
  position="bottom-right"
  theme="light"
  rich_colors={false}
  max_toasts={3}
  animation_duration={400}
  expanded={false}
/>
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `position` | string | `"bottom-right"` | Position of toasts: `"top-left"`, `"top-center"`, `"top-right"`, `"bottom-left"`, `"bottom-center"`, `"bottom-right"` |
| `theme` | string | `"light"` | Theme style: `"light"`, `"dark"`, or `"system"` (follows the OS light/dark setting via `prefers-color-scheme`) |
| `rich_colors` | boolean | `false` | Use more vibrant colors for toast types |
| `max_toasts` | integer | `3` | Maximum number of visible toasts |
| `animation_duration` | integer | `400` | Duration of animations in milliseconds |
| `connection_toasts` | boolean | `false` | Show an error toast while the LiveView is disconnected |
| `client_error_title` | string | `"We can't find the internet"` | Title when the client loses its connection |
| `client_error_message` | string | `"Attempting to reconnect"` | Message when the client loses its connection |
| `server_error_title` | string | `"Something went wrong!"` | Title when the server crashes |
| `server_error_message` | string | `"Hang in there while we get back on track"` | Message when the server crashes |
| `expanded` | boolean | `false` | Always show toasts expanded instead of stacked |

### Connection Toasts

Phoenix's generated layouts show `#client-error` and `#server-error` flashes when the
LiveView loses its connection. Set `connection_toasts` to show these as toasts instead,
then remove the two `<.flash>` elements from your layout:

```heex
<Toast.toast_group flash={@flash} connection_toasts={true} />
```

They use the same `phx-disconnected` and `phx-connected` bindings as Phoenix, so they
show while disconnected and hide on reconnect. Pass your own text to translate them:

```heex
<Toast.toast_group
  flash={@flash}
  connection_toasts={true}
  client_error_title={gettext("We can't find the internet")}
  client_error_message={gettext("Attempting to reconnect")}
  server_error_title={gettext("Something went wrong!")}
  server_error_message={gettext("Hang in there while we get back on track")}
/>
```

### Individual Toast Options

When sending toasts, you can configure:

```elixir
Toast.send_toast(:success, "Message",
  title: "Success!",
  description: "Additional details here",
  duration: 10_000,
  close_button: true,
  important: true,
  action: %{
    label: "Undo",
    event: "undo_action",
    params: %{id: 123}
  }
)
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `title` | string | `nil` | Toast title (displayed above message) |
| `description` | string | `nil` | Additional text (displayed below message) |
| `duration` | integer | `6000` | Auto-dismiss time in milliseconds (0 = no auto-dismiss) |
| `close_button` | boolean | `true` | Show close button |
| `important` | boolean | `false` | Use `aria-live="assertive"` for screen readers |
| `icon` | string | `nil` | Custom SVG icon HTML |
| `action` | map | `nil` | Action button configuration |

### Action Button Options

Actions can be configured with:

```elixir
action: %{
  label: "Button text",      # Required
  event: "event_name",       # Event to send to LiveView
  params: %{key: "value"},   # Optional parameters
  inline: true               # Show as inline button (default: false)
}
```

## Advanced Usage

### Custom Icons

Provide custom SVG icons:

```elixir
Toast.send_toast(:info, "Custom icon",
  icon: ~s(<svg>...</svg>)
)
```

### HTML Content

Toast supports rendering raw HTML in messages, titles, and descriptions using `Phoenix.HTML.raw/1`:

```elixir
# Basic HTML formatting
Toast.send_toast(:info, Phoenix.HTML.raw("<strong>Bold</strong> and <em>italic</em> text"))

# Rich HTML content
Toast.send_toast(:success, Phoenix.HTML.raw("Payment processed"),
  title: Phoenix.HTML.raw("Transaction <em>Complete</em>"),
  description: Phoenix.HTML.raw("ID: <code>TXN-12345</code>")
)

# Mixed content (some fields escaped, some raw)
Toast.send_toast(:info, "This is escaped: <script>",
  description: Phoenix.HTML.raw("This is <strong>HTML</strong>")
)
```

**⚠️ Security Warning**: Only use `Phoenix.HTML.raw/1` with trusted content. Never render user-generated HTML without proper sanitization as it can lead to XSS vulnerabilities.

### Update Existing Toasts

Update a toast after it's displayed:

```elixir
# Create with custom ID
Toast.send_toast(:loading, "Processing...", id: "upload-toast")

# Later, update it
Toast.update_toast("upload-toast",
  type: :success,
  message: "Upload complete!",
  duration: 3000
)
```

The toast is re-rendered in place. A new `duration` restarts its timer. Updating an ID that is no longer showing does nothing.

### Clear Toasts

Remove toasts programmatically:

```elixir
# Clear specific toast
Toast.clear_toast("toast-id")

# Clear all toasts
Toast.clear_all_toasts()
```


## Stacking Behavior

When multiple toasts are displayed:

- Toasts stack with the newest on top
- Hovering expands the stack to show all toasts
- Set `expanded={true}` to turn off stacking and always show toasts expanded
- Only `max_toasts` are visible (extras are queued)
- Toasts animate smoothly when added/removed

## CSS Customization

Toast uses CSS custom properties for easy theming:

```css
.live-toast-group {
  --toast-gap: 15px;
  --toast-width: 350px;
  --toast-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  --toast-animation-duration: 400ms;
}

/* Override specific toast types */
.toast-success {
  --toast-bg: #10b981;
  --toast-color: white;
}
```

## Content Security Policy

Toast renders no inline `style` attributes or `<style>` elements, so it works under a strict CSP such as `style-src 'self'` without `'unsafe-inline'`. Load `toast.css` as part of your own stylesheet. Any HTML you pass in yourself (custom icons, `Phoenix.HTML.raw/1` content) must also avoid inline styles.

## Acknowledgments

Toast was heavily influenced by:
- [Sonner](https://github.com/emilkowalski/sonner) - An opinionated toast component for React.
- [LiveToast](https://github.com/srcrip/live_toast) - A beautiful drop-in replacement for the Phoenix Flash system.
## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details.

