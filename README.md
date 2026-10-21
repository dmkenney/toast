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

These steps match a new Phoenix 1.8 app. Paths assume the default `assets/js/app.js` and `assets/css/app.css`.

### 1. JavaScript

In `assets/js/app.js`, import the hook and add it to your existing LiveSocket hooks. Keep the other options as they are:

```javascript
import Toast from "../../deps/toast/assets/js/toast.js"

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks, Toast},
})
```

On Phoenix 1.7 there is no `hooks` option yet, so add `hooks: {Toast}`.

### 2. CSS

In `assets/css/app.css`, import the stylesheet after the Tailwind import:

```css
@import "tailwindcss" source(none);
@import "../../deps/toast/assets/css/toast.css";
```

If you use daisyUI (the Phoenix 1.8 default), its `toast` class clashes with Toast's. Add `exclude: toast;` to your existing daisyUI plugin block:

```css
@plugin "daisyui/packages/bundle/daisyui" {
  themes: false;
  exclude: toast;
}
```

### 3. Layout

`Toast.toast_group` is a LiveComponent, so it must be rendered inside a LiveView. Do not put it in `root.html.heex`: the root layout is rendered outside the LiveView and every page fails with `cannot convert component Toast.LiveComponent ... to HTML`.

**Phoenix 1.8:** in `lib/my_app_web/components/layouts.ex`, replace `<.flash_group flash={@flash} />` in `Layouts.app` with `Toast.toast_group`. Set `connection_toasts` to keep the "We can't find the internet" and "Something went wrong!" messages from Phoenix's `flash_group` (the `#client-error` and `#server-error` flashes):

```elixir
attr :flash, :map, required: true, doc: "the map of flash messages"
attr :live, :boolean, default: true, doc: "set to false in controller templates"

def app(assigns) do
  ~H"""
  <%!-- generated <header> and <main> stay as they are --%>

  <Toast.toast_group :if={@live} flash={@flash} connection_toasts={true} />
  <div :if={!@live} class="live-toast-group toast-position-bottom-right">
    <Toast.Components.flash_group flash={@flash} />
  </div>
  """
end
```

Controller templates that use `Layouts.app` are not LiveViews, so they pass `live={false}` and get a plain flash list in the same style:

```heex
<Layouts.app flash={@flash} live={false}>
  ...
</Layouts.app>
```

Without `live={false}`, a controller page that uses `Layouts.app` fails with the same error as above. On controller pages the flash close button does nothing, because the JavaScript hook only runs in a LiveView.

**Phoenix 1.7:** `app.html.heex` is the layout for both LiveViews and controllers, and only LiveViews have `@socket`. Replace `<.flash_group flash={@flash} />` with:

```heex
<Toast.toast_group :if={assigns[:socket]} flash={@flash} connection_toasts={true} />
<div :if={!assigns[:socket]} class="live-toast-group toast-position-bottom-right">
  <Toast.Components.flash_group flash={@flash} />
</div>
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

Flash messages don't auto-dismiss. They stay until the user closes them. Use `put_toast` or `send_toast` for messages that should go away on their own.

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
| `id` | string | `"toast-group"` | DOM id of the toast list. Connection toasts use `"<id>-client-error"` and `"<id>-server-error"`. Render one toast group per page |
| `position` | string | `"bottom-right"` | Position of toasts: `"top-left"`, `"top-center"`, `"top-right"`, `"bottom-left"`, `"bottom-center"`, `"bottom-right"` |
| `theme` | string | `"light"` | Theme style: `"light"`, `"dark"`, or `"system"` (follows the OS light/dark setting via `prefers-color-scheme`) |
| `rich_colors` | boolean | `false` | Use more vibrant colors for toast types |
| `max_toasts` | integer | `3` | Maximum number of toasts shown. Older toasts beyond the limit are removed |
| `animation_duration` | integer | `400` | Duration of animations in milliseconds |
| `connection_toasts` | boolean | `false` | Show an error toast while the LiveView is disconnected |
| `client_error_title` | string | `"We can't find the internet"` | Title when the client loses its connection |
| `client_error_message` | string | `"Attempting to reconnect"` | Message when the client loses its connection |
| `server_error_title` | string | `"Something went wrong!"` | Title when the server crashes |
| `server_error_message` | string | `"Hang in there while we get back on track"` | Message when the server crashes |
| `expanded` | boolean | `false` | Always show toasts expanded instead of stacked |

### Connection Toasts

Phoenix's generated layouts show `#client-error` and `#server-error` flashes when the
LiveView loses its connection. Set `connection_toasts` to show these as toasts instead.
If you replaced `<.flash_group>` as shown in Setup, those flashes are already gone.
Otherwise remove the two `<.flash>` elements from your layout:

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

`send_toast` and `put_toast` take the same options:

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
| `id` | string | random | Toast id. Set it to update or clear the toast later |
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

Clicking the button closes the toast and sends `{event, params}` to the LiveView that sent the toast. Handle it in `handle_info/2`. The event arrives as an atom and `params` has string keys:

```elixir
def handle_event("delete", %{"id" => id}, socket) do
  Toast.send_toast(:info, "Item deleted",
    action: %{label: "Undo", event: "undo_delete", params: %{id: id}}
  )

  {:noreply, socket}
end

def handle_info({:undo_delete, %{"id" => id}}, socket) do
  # restore the item
  {:noreply, socket}
end
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
# Create with custom ID. duration: 0 keeps it open until it is updated
Toast.send_toast(:loading, "Processing...", id: "upload-toast", duration: 0)

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
- At most `max_toasts` are shown. Older toasts beyond the limit are removed
- Toasts animate smoothly when added/removed

## CSS Customization

Each toast reads its colors from CSS custom properties: `--toast-bg`, `--toast-color`, `--toast-border` and `--toast-icon-color`. Override them per type in your `app.css`, after the Toast import:

```css
.live-toast-group .toast-success {
  --toast-bg: #10b981;
  --toast-color: white;
  --toast-border: #059669;
  --toast-icon-color: white;
}
```

Set the animation speed with the `animation_duration` attribute, not CSS.

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

